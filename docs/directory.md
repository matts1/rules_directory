<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Skylib module containing rules to create metadata about directories.

<a id="directory"></a>

## directory

<pre>
directory(<a href="#directory-name">name</a>, <a href="#directory-srcs">srcs</a>, <a href="#directory-kwargs">kwargs</a>)
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


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="directory-name"></a>name |  (str) The name of the label.   |  none |
| <a id="directory-srcs"></a>srcs |  (List[Label|File]) The files contained within this directory and subdirectories.",   |  <code>[]</code> |
| <a id="directory-kwargs"></a>kwargs |  Kwargs to be passed to the underlying rule.   |  none |


