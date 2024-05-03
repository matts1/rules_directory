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

"""Unit tests for the directory_glob rule."""

load("@rules_testing//lib:truth.bzl", "matching")
load("//directory:providers.bzl", "DirectoryInfo")
load(
    "//directory:utils.bzl",
    "directory_glob",
    "directory_glob_chunk",
)
load(":utils.bzl", "failure_matching")

visibility("private")

def _expect_glob_chunk(env, directory, chunk):
    return env.expect.that_collection(
        [entry.value for entry in directory_glob_chunk(directory, chunk).to_list()],
        expr = "directory_glob_chunk({}, {})".format(directory.human_readable, repr(chunk)),
    )

def _expect_glob(env, directory, include, allow_empty = False):
    return env.expect.that_collection(
        directory_glob(directory, include, allow_empty = allow_empty).to_list(),
    )

def _with_children(children):
    return DirectoryInfo(
        entries = struct(**{k: k for k in children}),
        human_readable = repr(children),
    )

# buildifier: disable=function-docstring
def directory_glob_test(env, targets):
    f1 = targets.f1.files.to_list()[0]
    f2 = targets.f2.files.to_list()[0]
    f3 = targets.f3.files.to_list()[0]
    root = targets.root[DirectoryInfo]

    _expect_glob_chunk(env, root, "f1").contains_exactly([f1])
    _expect_glob_chunk(env, root, "nonexistent").contains_exactly([])
    _expect_glob_chunk(env, root, "f2").contains_exactly([])
    _expect_glob_chunk(env, root, "dir").contains_exactly([root.entries.dir])
    _expect_glob_chunk(env, root, "*").contains_exactly(
        [f1, root.entries.newdir, root.entries.dir],
    )
    _expect_glob_chunk(
        env,
        _with_children(["a", "d", "abc", "abbc", "ab.bc", ".abbc", "abbc."]),
        "ab*bc",
    ).contains_exactly([
        "abbc",
        "ab.bc",
    ])
    _expect_glob_chunk(
        env,
        _with_children(["abbc", "abbbc", "ab.b.bc"]),
        "ab*b*bc",
    ).contains_exactly([
        "abbbc",
        "ab.b.bc",
    ])

    _expect_glob(env, root, ["f1"]).contains_exactly([f1])
    _expect_glob(env, root, ["dir/subdir/f2"]).contains_exactly([f2])
    _expect_glob(env, root, ["**"]).contains_exactly([f1, f2, f3])
    _expect_glob(env, root, ["**/f1"]).contains_exactly([f1])
    _expect_glob(env, root, ["**/**/f1"]).contains_exactly([f1])
    _expect_glob(env, root, ["*/f1"], allow_empty = True).contains_exactly([])

    simple_glob = env.expect.that_target(targets.simple_glob)
    with_exclude = env.expect.that_target(targets.glob_with_exclude)

    simple_glob.default_outputs().contains_exactly([f1.path])
    with_exclude.default_outputs().contains_exactly([f1.path])

    # target.runfiles().contains_exactly() doesn't do what we want - it converts
    # it to a string corresponding to the runfiles import path.
    env.expect.that_collection(
        simple_glob.runfiles().actual.files.to_list(),
    ).contains_exactly([f1])
    env.expect.that_collection(
        with_exclude.runfiles().actual.files.to_list(),
    ).contains_exactly([f1, f2])

# buildifier: disable=function-docstring
directory_glob_with_no_match_test = failure_matching(matching.contains(
    '"nonexistent" failed to match any files in',
))
