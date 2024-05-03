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

load(":providers.bzl", "FileOrDirectoryInfo")

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
_NO_GLOB_MATCHES = "{glob} failed to match any files in {dir}"

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
        name: getattr(directory.entries, name)
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
    if require_dir and type(entry) == "File":
        fail(_WRONG_TYPE.format(
            dir = directory.human_readable,
            name = name,
            want = "Directory",
            got = "File",
        ))

    if require_file and type(entry) != "File":
        fail(_WRONG_TYPE.format(
            dir = directory.human_readable,
            name = name,
            want = "File",
            got = "Directory",
        ))
    return entry

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

def directory_glob_chunk(directory, chunk):
    """Given a directory and a chunk of a glob, returns possible candidates.

    Args:
        directory: (DirectoryInfo) The directory to look relative from.
        chunk: (string) A chunk of a glob to look at.

    Returns:
        depset[DirectoryOrFileInfo] The candidate next entries for the chunk.
    """
    if chunk == "*":
        return directory.direct_entries
    elif chunk == "**":
        return depset(
            [FileOrDirectoryInfo(value = directory)],
            transitive = [directory.transitive_entries],
        )
    elif "*" not in chunk:
        entry = getattr(directory.entries, chunk, None)
        if entry == None:
            return depset([])
        else:
            return depset([FileOrDirectoryInfo(value = entry)])
    elif chunk.count("*") > 2:
        fail("glob chunks with more than two asterixes are unsupported. Got", chunk)

    if chunk.count("*") == 2:
        left, middle, right = chunk.split("*")
    else:
        middle = ""
        left, right = chunk.split("*")
    entries = []
    for path in dir(directory.entries):
        if path.startswith(left) and path.endswith(right) and len(left) + len(right) <= len(path) and middle in path[len(left):-len(right)]:
            entries.append(FileOrDirectoryInfo(value = getattr(directory.entries, path)))
    return depset(entries)

def directory_single_glob(directory, glob):
    """Calculates all files that are matched by a glob on a directory.

    Args:
        directory: (DirectoryInfo) The directory to look relative from.
        glob: (string) A glob to match.

    Returns:
        List[File] A list of files that match.
    """

    # Treat a glob as a nondeterministic finite state automata. We can be in
    # multiple places at the one time.
    candidate_dirs = [directory]
    candidate_files = []
    for chunk in glob.split("/"):
        new_candidates = []
        for candidate in candidate_dirs:
            new_candidates.append(directory_glob_chunk(candidate, chunk))

        candidate_dirs = []
        candidate_files = []
        for candidate in depset(transitive = new_candidates).to_list():
            if type(candidate.value) == "File":
                candidate_files.append(candidate.value)
            else:
                candidate_dirs.append(candidate.value)

    return candidate_files

def directory_glob(directory, include, allow_empty = False):
    """native.glob, but for DirectoryInfo.

    Args:
        directory: (DirectoryInfo) The directory to look relative from.
        include: (List[string]) A list of globs to match.
        allow_empty: (bool) Whether to allow a glob to not match any files.

    Returns:
        depset[File] A set of files that match.
    """
    include_files = []
    for g in include:
        matches = directory_single_glob(directory, g)
        if not matches and not allow_empty:
            fail(_NO_GLOB_MATCHES.format(
                glob = repr(g),
                dir = directory.human_readable,
            ))
        include_files.extend(matches)
    return depset(include_files)
