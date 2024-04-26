<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Skylib module containing rules to create metadata about directories.

<a id="directory"></a>

## directory

<pre>
directory(<a href="#directory-name">name</a>, <a href="#directory-srcs">srcs</a>)
</pre>

A marker for a bazel directory and its contents.

Example usage:
directory(
    name = "foo",
    srcs = glob(
        ["**/*"],
        exclude=["BUILD.bazel", "WORKSPACE.bazel", "MODULE.bazel"])
    )
)


**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="directory-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="directory-srcs"></a>srcs |  The files contained within this directory and subdirectories.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | required |  |


