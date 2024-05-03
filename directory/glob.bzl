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
"""Rules to filter files from a directory."""

load(":providers.bzl", "DirectoryInfo")
load(":utils.bzl", _directory_glob = "directory_glob")

def _remove_exclude(files, exclude):
    # to_list is expensive. Avoid running it if possible.
    if not exclude:
        return files
    return depset([f for f in files.to_list() if f not in exclude])

def _directory_glob_impl(ctx):
    directory = ctx.attr.directory[DirectoryInfo]
    allow_empty = ctx.attr.allow_empty
    exclude = {
        k: None
        for k in _directory_glob(
            directory,
            ctx.attr.exclude,
            allow_empty = allow_empty,
        ).to_list()
    }
    srcs = _remove_exclude(
        _directory_glob(directory, ctx.attr.srcs, allow_empty = allow_empty),
        exclude,
    )
    data = _remove_exclude(
        _directory_glob(directory, ctx.attr.data, allow_empty = allow_empty),
        exclude,
    )

    return DefaultInfo(
        files = srcs,
        runfiles = ctx.runfiles(transitive_files = depset(transitive = [srcs, data])),
    )

directory_glob = rule(
    implementation = _directory_glob_impl,
    attrs = {
        "allow_empty": attr.bool(
            doc = "If true, allows globs to not match anything.",
        ),
        "data": attr.string_list(
            doc = """A list of globs to files within the directory to put in the runfiles.

For example, `data = ["foo/**"]` would collect all files contained within `<directory>/foo` into the
runfiles.""",
        ),
        "directory": attr.label(providers = [DirectoryInfo], mandatory = True),
        "exclude": attr.string_list(
            doc = "A list of globs to files within the directory to exclude from the files and runfiles.",
        ),
        "srcs": attr.string_list(
            doc = """A list of globs to files within the directory to put in the files.

For example, `srcs = ["foo/**"]` would collect the file at `<directory>/foo` into the
files.""",
        ),
    },
    doc = """globs files from a directory by relative path.

Usage:

```
directory_glob(
    name = "foo",
    directory = ":directory",
    srcs = ["foo/bar"],
    data = ["foo/**"],
    exclude = ["foo/**/*.h"]
)
```
""",
)
