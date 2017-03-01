# Changelog

## 2.1.0 (2017-03-01)

### Enhancements

* Added `readContent(path)` to read the raw content of any file. Thanks @LegNeato!
* Exposed `usingFileStream(path, action)` that allows you to consume the contents of a file as a Stream. Useful for very large files.

### Fixes

* `readXml(path)` was unable to read any other file than `AndroidManifest.xml` due to an oversight. You can now read any file with it.

## 2.0.0 (2017-01-24)

### Breaking changes

It was discovered that our previous Zip parser, [adm-zip](https://github.com/cthackers/adm-zip), could not handle all valid Zip formats. We've therefore switched to [yauzl](https://github.com/thejoshwolfe/yauzl) which provides an asynchronous interface. Therefore the following breaking API changes were required:

* Replaced `ApkReader.readFile()` with a Promise-returning `ApkReader.open()` which describes it better, and we have no way of supporting the previous synchronous method with the new dependency.
* Replaced `ApkReader.readManifestSync()` with a Promise-returning `ApkReader.readManifest()` as we have no way of supporting the synchronous method with the new dependency.
* Replaced `ApkReader.readXmlSync()` with a Promise-returning `ApkReader.readXml()` as we have no way of supporting the synchronous method with the new dependency.
