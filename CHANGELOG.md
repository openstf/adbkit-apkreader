# Changelog

## HEAD

### Breaking changes

It was discovered that our previous Zip parser, [adm-zip](https://github.com/cthackers/adm-zip), could not handle all valid Zip formats. We've therefore switched to [yauzl](https://github.com/thejoshwolfe/yauzl) which provides an asynchronous interface. Therefore the following breaking API changes were required:

* Replaced `ApkReader.readFile()` with a Promise-returning `ApkReader.open()` which describes it better, and we have no way of supporting the previous synchronous method with the new dependency.
* Replaced `ApkReader.readManifestSync()` with a Promise-returning `ApkReader.readManifest()` as we have no way of supporting the synchronous method with the new dependency.
* Replaced `ApkReader.readXmlSync()` with a Promise-returning `ApkReader.readXml()` as we have no way of supporting the synchronous method with the new dependency.
