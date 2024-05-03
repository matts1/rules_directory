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

"""Unit tests for the directory_filter rule."""

visibility("private")

# buildifier: disable=function-docstring
def directory_filter_test(env, targets):
    f2 = targets.f2.files.to_list()[0]
    f3 = targets.f3.files.to_list()[0]

    target = env.expect.that_target(targets.filtered)
    target.default_outputs().contains_exactly([f2.path])

    # target.runfiles().contains_exactly() doesn't do what we want - it converts
    # it to a string corresponding to the runfiles import path.
    env.expect.that_collection(
        target.runfiles().actual.files.to_list(),
    ).contains_exactly([f2, f3])
