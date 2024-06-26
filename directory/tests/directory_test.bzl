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

"""Unit tests for the directory rule."""

load("@rules_testing//lib:truth.bzl", "matching")
load("//directory:providers.bzl", "DirectoryInfo")
load("//directory:utils.bzl", "directory_path")
load(":utils.bzl", "directory_subject", "failure_matching")

visibility("private")

# buildifier: disable=function-docstring
outside_testdata_test = failure_matching(matching.contains(
    "directory/tests/BUILD.bazel is not contained within @@//directory/tests/testdata",
))

# buildifier: disable=function-docstring
def directory_test(env, targets):
    f1 = targets.f1.files.to_list()[0]
    f2 = targets.f2.files.to_list()[0]
    f3 = targets.f3.files.to_list()[0]

    env.expect.that_collection(targets.root.files.to_list()).contains_exactly(
        [f1, f2, f3],
    )

    root = directory_subject(env, targets.root[DirectoryInfo])
    root.entries().keys().contains_exactly(["dir", "newdir", "f1"])
    root.transitive_files().contains_exactly([f1, f2, f3]).in_order()
    root.human_readable().equals("@@//directory/tests/testdata")
    env.expect.that_str(root.actual.source_path + "/f1").equals(f1.path)
    env.expect.that_str(root.actual.generated_path + "/newdir/f3").equals(f3.path)

    dir = directory_subject(env, root.actual.entries.dir)
    dir.entries().keys().contains_exactly(["subdir"])
    dir.human_readable().equals("@@//directory/tests/testdata/dir")

    subdir = directory_subject(env, dir.actual.entries.subdir)
    subdir.entries().contains_exactly({"f2": f2})
    subdir.transitive_files().contains_exactly([f2])
    env.expect.that_str(subdir.actual.source_path + "/f2").equals(f2.path)
    subdir.generated_path().equals(None)
    env.expect.that_str(directory_path(subdir.actual)).equals(
        subdir.actual.source_path,
    )

    newdir = directory_subject(env, root.actual.entries.newdir)
    newdir.entries().contains_exactly({"f3": f3})
    newdir.transitive_files().contains_exactly([f3]).in_order()
    env.expect.that_str(newdir.actual.generated_path + "/f3").equals(f3.path)
    newdir.source_path().equals(None)
    env.expect.that_str(directory_path(newdir.actual)).equals(
        newdir.actual.generated_path,
    )

# buildifier: disable=function-docstring
def directory_with_no_srcs_test(env, targets):
    f1 = targets.f1.files.to_list()[0]
    f3 = targets.f3.files.to_list()[0]

    env.expect.that_collection(targets.dir.files.to_list()).contains_exactly([])

    d = directory_subject(env, targets.dir[DirectoryInfo])
    d.entries().contains_exactly({})
    env.expect.that_str(d.actual.source_path + "/f1").equals(f1.path)
    env.expect.that_str(d.actual.generated_path + "/newdir/f3").equals(f3.path)

# buildifier: disable=function-docstring
directory_with_self_srcs_test = failure_matching(matching.contains(
    "directory/tests/testdata is not contained within @@//directory/tests/testdata",
))
