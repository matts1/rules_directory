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

"""Skylib module containing providers for directories."""

visibility("public")

DirectoryOrFileInfo = provider(
    doc = "Information about either a directory or a file",
    # Represents Either[DirectoryInfo], File]
    fields = {
        "value": "(Either[File, DirectoryInfo]) A directory or a file",
    },
)

DirectoryInfo = provider(
    doc = "Information about a directory",
    # @unsorted-dict-items
    fields = {
        # Entries uses a struct as if it were a dictionary.
        # For example, a directory containing a single file named foo would look
        # like:
        # struct(**{foo.basename: DirectoryOrFileInfo(file=foo)})
        # This is because bazel doesn't allow depsets of structs containing
        # dicts. This should be solved with
        # https://github.com/bazelbuild/bazel/pull/22166
        "entries": "(Struct[str, DirectoryOrFileInfo]) The entries contained directly within",
        "direct_entries": "depset[DirectoryOrFileInfo] All files and directories directly within this directory.",
        "transitive_entries": "(depset[DirectoryOrFileInfo]) All files and directories transitively contained within this directory.",
        "transitive_files": "(depset[File]) All files transitively contained within this directory.",
        "source_path": "(string) Path to all source files contained within this directory",
        "generated_path": "(string) Path to all generated files contained within this directory",
        "human_readable": "(string) A human readable identifier for a directory. Useful for providing error messages to a user.",
    },
)
