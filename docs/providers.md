<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Skylib module containing providers for directories.

<a id="DirectoryInfo"></a>

## DirectoryInfo

<pre>
DirectoryInfo(<a href="#DirectoryInfo-entries">entries</a>, <a href="#DirectoryInfo-direct_entries">direct_entries</a>, <a href="#DirectoryInfo-transitive_entries">transitive_entries</a>, <a href="#DirectoryInfo-transitive_files">transitive_files</a>, <a href="#DirectoryInfo-source_path">source_path</a>,
              <a href="#DirectoryInfo-generated_path">generated_path</a>, <a href="#DirectoryInfo-human_readable">human_readable</a>)
</pre>

Information about a directory

**FIELDS**


| Name  | Description |
| :------------- | :------------- |
| <a id="DirectoryInfo-entries"></a>entries |  (Struct[str, FileOrDirectoryInfo]) The entries contained directly within    |
| <a id="DirectoryInfo-direct_entries"></a>direct_entries |  depset[FileOrDirectoryInfo] All files and directories directly within this directory.    |
| <a id="DirectoryInfo-transitive_entries"></a>transitive_entries |  (depset[FileOrDirectoryInfo]) All files and directories transitively contained within this directory.    |
| <a id="DirectoryInfo-transitive_files"></a>transitive_files |  (depset[File]) All files transitively contained within this directory.    |
| <a id="DirectoryInfo-source_path"></a>source_path |  (string) Path to all source files contained within this directory    |
| <a id="DirectoryInfo-generated_path"></a>generated_path |  (string) Path to all generated files contained within this directory    |
| <a id="DirectoryInfo-human_readable"></a>human_readable |  (string) A human readable identifier for a directory. Useful for providing error messages to a user.    |


<a id="FileOrDirectoryInfo"></a>

## FileOrDirectoryInfo

<pre>
FileOrDirectoryInfo(<a href="#FileOrDirectoryInfo-value">value</a>)
</pre>

Information about either a directory or a file

**FIELDS**


| Name  | Description |
| :------------- | :------------- |
| <a id="FileOrDirectoryInfo-value"></a>value |  (Either[File, DirectoryInfo]) A directory or a file    |


