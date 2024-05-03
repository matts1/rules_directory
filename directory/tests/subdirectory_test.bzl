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

"""Unit tests for subdirectory rules."""

load("@rules_testing//lib:truth.bzl", "matching")
load("//directory:providers.bzl", "DirectoryInfo")
load(":utils.bzl", "failure_matching")

visibility("private")

# buildifier: disable=function-docstring
def subdirectory_test(env, targets):
    f2 = targets.f2.files.to_list()[0]

    root = targets.root[DirectoryInfo]
    want_dir = root.entries.dir
    want_subdir = want_dir.entries.subdir

    # Use that_str because it supports equality checks. They're not strings.
    env.expect.that_str(targets.dir[DirectoryInfo]).equals(want_dir)
    env.expect.that_str(targets.subdir[DirectoryInfo]).equals(want_subdir)

    env.expect.that_collection(
        targets.dir.files.to_list(),
    ).contains_exactly([f2])
    env.expect.that_collection(
        targets.subdir.files.to_list(),
    ).contains_exactly([f2])

nonexistent_subdirectory_test = failure_matching(matching.contains(
    """ does not contain an entry named "nonexistent".
Instead, it contains the following entries:
subdir
""",
))

subdirectory_as_file_test = failure_matching(matching.contains(
    "f1 to have type Directory, but got File",
))

subdirectory_of_file_test = failure_matching(matching.contains(
    "f1 to have type Directory, but got File",
))
