load("@bazel_skylib//rules:copy_file.bzl", "copy_file")
load("@rules_testing//lib:util.bzl", "util")
load("//directory:directory.bzl", "directory")

package(default_visibility = ["//directory/tests:__pkg__"])

copy_file(
    name = "f3",
    src = "dir/subdir/f2",
    out = "newdir/f3",
)

directory(
    name = "root",
    srcs = glob(
        ["**"],
        exclude = ["BUILD"],
    ) + [":f3"],
)

util.helper_target(
    directory,
    name = "outside_testdata",
    srcs = glob(
        ["**"],
        exclude = ["BUILD"],
    ) + ["//directory/tests:outside_testdata"],
)

filegroup(
    name = "f1_filegroup",
    srcs = ["f1"],
)

filegroup(
    name = "f2_filegroup",
    srcs = ["dir/subdir/f2"],
)
