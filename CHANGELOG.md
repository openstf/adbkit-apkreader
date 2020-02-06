# Changelog

## 3.2.0 (2020-02-06)

### Fixes

* Updated dependencies

## 3.1.2 (2019-01-18)

### Fixes

* Fixed a file reference leak when a ZIP-related error was encountered when reading an APK file. Thanks @harlentan!

## 3.1.1 (2018-11-11)

### Fixes

* Fixed manifest parsing on applications processed by 360 encryption services, which changes the `application` key to `com.stub.StubApp`. Thanks @JChord!

## 3.1.0 (2018-09-27)

### Fixes

* Fixed parsing of certain APKs that deduplicate items in the string pool.

### Enhancements

* Optional structured debug output can be enabled by passing `debug: true` to `.readManifest()` or `.readXml()`.

## 3.0.2 (2018-07-11)

### Fixes

* Fixed parsing of Chrome 68 Beta APK and other similar APKs with a missing XML namespace. Thanks @zr0827!

## 3.0.1 (2018-04-20)

### Fixes

* Fixed parsing of long strings. Thanks @mingyuan-xia!

## 3.0.0 (2017-09-21)

### Enhancements

* Got rid of CoffeeScript.

### Breaking changes

* Dropped support for older Node.js versions. You need at least 4.x or newer now.

## 2.1.2 (2017-08-21)

### Fixes

* Fixed a `RangeError: Index out of range` error when parsing newer APKs that use UTF-8 encoding for their string pools. Thanks to @headshot289 and @mingyuan-xia for providing samples that helped isolate the issue.

## 2.1.1 (2017-03-07)

### Enhancements

* Fixed a `readManifest()` parsing issue with slightly malformed manifests.

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
