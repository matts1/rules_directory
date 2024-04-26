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

"""Helper functions for testing directory rules."""

load("@rules_testing//lib:truth.bzl", "subjects")

visibility("private")

_depset_as_list_subject = lambda value, *, meta: subjects.collection(
    value.to_list(),
    meta = meta,
)

_entry_struct = lambda value, *, meta: subjects.dict(
    {k: getattr(value, k).value for k in dir(value)},
    meta = meta,
)

directory_info_subject = lambda value, *, meta: subjects.struct(
    value,
    meta = meta,
    attrs = dict(
        entries = _entry_struct,
        direct_entries = _depset_as_list_subject,
        transitive_entries = _depset_as_list_subject,
        transitive_files = _depset_as_list_subject,
        source_path = subjects.str,
        generated_path = subjects.str,
        human_readable = subjects.str,
    ),
)

def failure_matching(matcher):
    def test(env, target):
        env.expect.that_target(target).failures().contains_exactly_predicates([
            matcher,
        ])

    return test

def directory_subject(env, directory_info):
    return env.expect.that_value(
        value = directory_info,
        expr = "DirectoryInfo(%r)" % directory_info.source_path,
        factory = directory_info_subject,
    )
