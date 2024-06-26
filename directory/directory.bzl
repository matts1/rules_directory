# Copyright 2024 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Skylib module containing rules to create metadata about directories."""

load(
    ":providers.bzl",
    "DirectoryInfo",
    "FileOrDirectoryInfo",
)

visibility("public")

def _directory_impl(ctx):
    if dir(struct()):
        fail("rules_directory requires --incompatible_struct_has_no_methods")

    source_dir = ctx.file.self.path
    source_prefix = source_dir + "/"

    # Declare a generated file so that we can get the path to generated files.
    f = ctx.actions.declare_file(ctx.label.name)
    ctx.actions.write(f, "")
    generated_dir = f.path.rsplit("/", 1)[0]
    generated_prefix = generated_dir + "/"

    root_metadata = struct(
        directories = {},
        files = [],
        source_path = source_dir,
        generated_path = generated_dir,
        human_readable = "@@%s//%s" % (
            # repo_name is only available in bazel 7+
            ctx.label.repo_name if hasattr(ctx.label, "repo_name") else ctx.label.workspace_name,
            ctx.label.package,
        ),
    )

    # Topologically order directories so we can use them for DFS.
    topo = [root_metadata]
    for src in ctx.files.srcs:
        prefix = source_prefix if src.is_source else generated_prefix
        if not src.path.startswith(prefix):
            fail("{path} is not contained within {prefix}".format(
                path = src.path,
                prefix = root_metadata.human_readable,
            ))
        relative = src.path[len(prefix):].split("/")
        current_path = root_metadata
        for dirname in relative[:-1]:
            if dirname not in current_path.directories:
                dir_metadata = struct(
                    directories = {},
                    files = [],
                    source_path = "%s/%s" % (current_path.source_path, dirname),
                    generated_path = "%s/%s" % (current_path.generated_path, dirname),
                    human_readable = "%s/%s" % (current_path.human_readable, dirname),
                )
                current_path.directories[dirname] = dir_metadata
                topo.append(dir_metadata)

            current_path = current_path.directories[dirname]

        if src.is_directory:
            kind = "source" if src.is_source else "generated"
            current_path.dir_file[kind] = src
        else:
            current_path.files.append(src)

    # The output DirectoryInfos. Key them by something arbitrary but unique.
    # In this case, we choose source_path.
    out = {}
    for dir_metadata in reversed(topo):
        directories = {
            dirname: out[subdir_metadata.source_path]
            for dirname, subdir_metadata in sorted(dir_metadata.directories.items())
        }
        entries = {
            file.basename: file
            for file in dir_metadata.files
        }
        entries.update(directories)
        has_source = any([d.source_path for d in directories.values()]) or any([f.is_source for f in dir_metadata.files])
        has_generated = any([d.generated_path for d in directories.values()]) or any([not f.is_source for f in dir_metadata.files])

        # If the directory is completely entry, this is clearly being used as a
        # simple directory marker, so we should provide both source_path and
        # generated_path.
        if not has_source and not has_generated:
            has_source = True
            has_generated = True

        direct_entries = depset([
            # Depsets can't contain multiple types, so wrap it in a struct.
            FileOrDirectoryInfo(value = v)
            for _, v in sorted(entries.items())
        ])
        transitive_entries = depset(
            transitive = [direct_entries] + [
                d.transitive_entries
                for d in directories.values()
            ],
            order = "preorder",
        )

        transitive_files = depset(
            direct = sorted(dir_metadata.files, key = lambda f: f.basename),
            transitive = [
                d.transitive_files
                for d in directories.values()
            ],
            order = "preorder",
        )
        directory = DirectoryInfo(
            entries = struct(**entries),
            direct_entries = direct_entries,
            transitive_entries = transitive_entries,
            transitive_files = transitive_files,
            source_path = dir_metadata.source_path if has_source else None,
            generated_path = dir_metadata.generated_path if has_generated else None,
            human_readable = dir_metadata.human_readable,
        )
        depset([directory])
        out[dir_metadata.source_path] = directory

    root_directory = out[root_metadata.source_path]

    return [
        root_directory,
        DefaultInfo(files = root_directory.transitive_files),
    ]

_directory = rule(
    implementation = _directory_impl,
    attrs = {
        "srcs": attr.label_list(
            allow_files = True,
        ),
        "self": attr.label(allow_single_file = True, mandatory = True),
    },
    provides = [DirectoryInfo],
)

def directory(name, srcs = [], **kwargs):
    """A marker for a bazel directory and its contents.

    Example usage:
    directory(
        name = "foo",
        srcs = glob(
            ["**/*"],
            exclude=["BUILD.bazel", "WORKSPACE.bazel", "MODULE.bazel"])
        )
    )

    Args:
        name: (str) The name of the label.
        srcs: (List[Label|File]) The files contained within this directory and
          subdirectories.",
        **kwargs: Kwargs to be passed to the underlying rule.
    """
    _directory(name = name, srcs = srcs, self = ".", **kwargs)
