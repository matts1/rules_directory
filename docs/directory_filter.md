<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Rules to filter files from a directory.

<a id="directory_filter"></a>

## directory_filter

<pre>
directory_filter(<a href="#directory_filter-name">name</a>, <a href="#directory_filter-data">data</a>, <a href="#directory_filter-directory">directory</a>, <a href="#directory_filter-srcs">srcs</a>)
</pre>

Extracts files from a directory by relative path.

Usage:

```
directory_filter(
    name = "clang",
    directory = "//:sysroot",
    srcs = ["usr/bin/clang"],
    data = ["lib/libc.so.6"],
)
```


**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="directory_filter-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="directory_filter-data"></a>data |  A list of relative paths to files within the directory to put in the files.<br><br>For example, <code>data = ["foo/bar"]</code> would collect the file at <code>&lt;directory&gt;/foo/bar</code> into the runfiles.   | List of strings | optional | <code>[]</code> |
| <a id="directory_filter-directory"></a>directory |  -   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |
| <a id="directory_filter-srcs"></a>srcs |  A list of relative paths to files within the directory to put in the runfiles.<br><br>For example, <code>srcs = ["foo/bar"]</code> would collect the file at <code>&lt;directory&gt;/foo/bar</code> into the files.   | List of strings | optional | <code>[]</code> |


