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
load(":utils.bzl", "get_relative")

def _directory_filter_impl(ctx):
    directory = ctx.attr.directory[DirectoryInfo]
    srcs = depset([
        get_relative(directory, path, require_file = True)
        for path in ctx.attr.srcs
    ])
    data = [
        get_relative(directory, path, require_file = True)
        for path in ctx.attr.data
    ]

    return DefaultInfo(
        files = srcs,
        runfiles = ctx.runfiles(files = data, transitive_files = srcs),
    )

directory_filter = rule(
    implementation = _directory_filter_impl,
    attrs = {
        "data": attr.string_list(
            doc = """A list of relative paths to files within the directory to put in the files.

For example, `data = ["foo/bar"]` would collect the file at `<directory>/foo/bar` into the
runfiles.""",
        ),
        "directory": attr.label(providers = [DirectoryInfo], mandatory = True),
        "srcs": attr.string_list(
            doc = """A list of relative paths to files within the directory to put in the runfiles.

For example, `srcs = ["foo/bar"]` would collect the file at `<directory>/foo/bar` into the
files.""",
        ),
    },
    doc = """Extracts files from a directory by relative path.

Usage:

```
directory_filter(
    name = "clang",
    directory = "//:sysroot",
    srcs = ["usr/bin/clang"],
    data = ["lib/libc.so.6"],
)
```
""",
)
