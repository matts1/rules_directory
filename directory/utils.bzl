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

"""Skylib module containing utility functions related to directories."""

visibility("public")

_NOT_FOUND = """{directory} does not contain an entry named {name}.
Instead, it contains the following entries:
{children}

"""
_WRONG_TYPE = "Expected {dir}/{name} to have type {want}, but got {got}"
_MULTIPLE_DIRS = (
    "The directory {dir} has both source files and generated files contained " +
    "within. Thus, it doesn't have a single path to access the contents from."
)
_NO_FILES = (
    "The directory {dir} doesn't contain any files, and thus doesn't have a " +
    "path."
)

def _check_path_relative(path):
    if path.startswith("/"):
        fail("Path must be relative. Got {path}".format(path = path))

def get_children(directory):
    """Gets all children of a directory.

    Args:
        directory: The directory to look within.

    Returns:
        dict[str, File|DirectoryInfo]
    """
    return {
        name: getattr(directory.entries, name).value
        for name in sorted(dir(directory.entries))
    }

def get_child(directory, name, require_dir = False, require_file = False):
    """Gets the direct child of a directory.

    Args:
        directory: (DirectoryInfo) The directory to look within.
        name: (string) The name of the directory/file to look for.
        require_dir: (bool) If true, throws an error if the value is not a
            directory.
        require_file: (bool) If true, throws an error if the value is not a
            file.

    Returns:
        (File|DirectoryInfo) The content contained within.
    """
    entry = getattr(directory.entries, name, None)
    if entry == None:
        fail(_NOT_FOUND.format(
            directory = directory.human_readable,
            name = repr(name),
            children = "\n".join(get_children(directory).keys()),
        ))
    result = entry.value
    if require_dir and type(result) == "File":
        fail(_WRONG_TYPE.format(
            dir = directory.human_readable,
            name = name,
            want = "Directory",
            got = "File",
        ))

    if require_file and type(result) != "File":
        fail(_WRONG_TYPE.format(
            dir = directory.human_readable,
            name = name,
            want = "File",
            got = "Directory",
        ))
    return entry.value

def get_relative(directory, path, require_dir = False, require_file = False):
    """Gets a subdirectory contained within a tree of another directory.

    Args:
        directory: (DirectoryInfo) The directory to look within.
        path: (string) The path of the directory to look for within it.
        require_dir: (bool) If true, throws an error if the value is not a
            directory.
        require_file: (bool) If true, throws an error if the value is not a
            file.

    Returns:
        (File|DirectoryInfo) The directory contained within.
    """
    _check_path_relative(path)

    chunks = path.split("/")
    for dirname in chunks[:-1]:
        directory = get_child(directory, dirname, require_dir = True)
    return get_child(
        directory,
        chunks[-1],
        require_dir = require_dir,
        require_file = require_file,
    )

def directory_path(directory):
    """Gets the path of a directory.

    Args:
        directory: (DirectoryInfo) The directory to look at.

    Returns:
        (string) The path to the directory's contents.
    """
    if directory.source_path and directory.generated_path:
        fail(_MULTIPLE_DIRS.format(dir = directory.human_readable))

    path = directory.source_path or directory.generated_path
    if not path:
        fail(_NO_FILES.format(dir = directory.human_readable))
    return path
