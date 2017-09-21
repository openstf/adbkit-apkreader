# adbkit-apkreader

**adbkit-apkreader** provides a [Node.js](http://nodejs.org/) API for extracting information from Android APK files. For example, it allows you to read the `AndroidManifest.xml` of an existing APK file.

## Requirements

* [Node.js](http://nodejs.org/) 4.x or newer. Older versions are not supported.

## Getting started

Install via NPM:

```bash
npm install --save adbkit-apkreader
```

### Examples

#### Read the `AndroidManifest.xml` of an APK

```javascript
const util = require('util')
const ApkReader = require('adbkit-apkreader')

ApkReader.open('HelloApp.apk')
  .then(reader => reader.readManifest())
  .then(manifest => console.log(util.inspect(manifest, { depth: null })))
```

## API

### ApkReader

#### ApkReader.MANIFEST

A convenience constant with the value `'AndroidManifest.xml'`. Can use useful with other API methods in certain circumstances.

#### ApkReader.open(file)

Alternate syntax to manually creating an ApkReader instance. Currently, only files are supported, but support for streams might be added at some point.

Note that currently this method cannot reject as the file is opened lazily, but this may change in the future and therefore returns a Promise for fewer future compatibility issues. On a related node, calling the constructor directly is still possible, but discouraged.

* **file** The path to the APK file.
* Returns: A `Promise` that resolves with an `ApkReader` instance.

#### reader.readContent(path)

Reads the content of the given file inside the APK.

* **path** The path to the file. For example, giving `'META-INF/MANIFEST.MF'` as the path would read the content of that file.
* Returns: A `Promise` that resolves with a `Buffer` containing the full contents of the file.

#### reader.readManifest()

Reads and parses the `AndroidManifest.xml` file inside the APK and returns a simplified object representation of it.

* Returns: A `Promise` that resolves with a JavaScript `Object` representation of the manifest. See example output below. Rejects on error (e.g. if parsing was unsuccessful).

```javascript
{ versionCode: 1,
  versionName: '1.0',
  package: 'com.example.hello.helloapp.app',
  usesPermissions: [],
  permissions: [],
  permissionTrees: [],
  permissionGroups: [],
  instrumentation: null,
  usesSdk: { minSdkVersion: 7, targetSdkVersion: 19 },
  usesConfiguration: null,
  usesFeatures: [],
  supportsScreens: null,
  compatibleScreens: [],
  supportsGlTextures: [],
  application:
   { theme: 'resourceId:0x7f0b0000',
     label: 'resourceId:0x7f0a000e',
     icon: 'resourceId:0x7f020057',
     debuggable: true,
     allowBackup: true,
     activities:
      [ { label: 'resourceId:0x7f0a000e',
          name: 'com.example.hello.helloapp.app.MainActivity',
          intentFilters:
           [ { actions: [ { name: 'android.intent.action.MAIN' } ],
               categories: [ { name: 'android.intent.category.LAUNCHER' } ],
               data: [] } ],
          metaData: [] } ],
     activityAliases: [],
     launcherActivities:
      [ { label: 'resourceId:0x7f0a000e',
          name: 'com.example.hello.helloapp.app.MainActivity',
          intentFilters:
           [ { actions: [ { name: 'android.intent.action.MAIN' } ],
               categories: [ { name: 'android.intent.category.LAUNCHER' } ],
               data: [] } ],
          metaData: [] } ],
     services: [],
     receivers: [],
     providers: [],
     usesLibraries: [] } }
```

#### reader.readXml(path)

Reads and parses the binary XML file at the given path inside the APK file. Attempts to be somewhat compatible with the DOM API.

* **path** The path to the binary XML file inside the APK. For example, giving `'AndroidManifest.xml'` as the path would parse the manifest (but you'll probably want to use `reader.readManifest()` instead).
* Returns: A `Promise` that resolves with a JavaScript `Object` representation of the root node of the XML file. All nodes including the root node have the properties listed below. Rejects on error (e.g. if parsing was unsuccessful).
    - **namespaceURI** The namespace URI or `null` if none.
    - **nodeType** `1` for element nodes, `2` for attribute nodes, and `4` for CData sections.
    - **nodeName** The node name.
    - For element nodes, the following additional properties are present:
        * **attributes** An array of attribute nodes.
        * **childNodes** An array of child nodes.
    - For attribute nodes, the following additional properties are present:
        * **name** The attribute name.
        * **value** The attribute value, if possible to represent as a simple value.
        * **typedValue** May be available when the attribute represents a complex value. See [android.util.TypedValue](http://developer.android.com/reference/android/util/TypedValue.html) for more information. Has the following properties:
            - **value** The value, which might `null`, `String`, `Boolean`, `Number` or even an `Object` for the most complex types.
            - **type** A `String` representation of the type of the value.
            - **rawType** A raw integer presentation of the type of the value.
    - For CData nodes, the following additional properties are present:
        * **data** The CData.
        * **typedValue** May be available if the section represents a more complex type. See above for details.

#### reader.usingFileStream(path, action)

Opens a readable Stream to the given file inside the APK and runs the given action with it. The APK file is kept open while the action runs, allowing you to process the stream. Once the action finishes, the APK will be automatically closed.

* **path** The path to the file. For example, giving `'META-INF/MANIFEST.MF'` as the path would open that file.
* **action(stream)** A function that processes the stream somehow. **MUST** return a `Promise` that resolves when you're done processing the stream. The value that the `Promise` resolves with will also be the value that `usingFileStream()` resolves with.
    - **stream** A readable Stream of the file content. You should either consume or end the stream yourself before resolving the action.
* Returns: A `Promise` that resolves with whatever `action` resolves with.

## More information

* [android.util.TypedValue](http://developer.android.com/reference/android/util/TypedValue.html) For more information about value types.
* [Dong Liu's excellent Java-based APK parser](https://github.com/xiaxiaocao/apk-parser), which was used as a reference implementation.
* [A detailed blog port about Android's binary XML format](http://justanapplication.wordpress.com/category/android/android-binary-xml/)
* [Stackoverflow discussion about the topic](http://stackoverflow.com/questions/2097813/how-to-parse-the-androidmanifest-xml-file-inside-an-apk-package)
* [android-apktool](https://code.google.com/p/android-apktool/) The most advanced CLI/Java-based APK tool.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

See [LICENSE](LICENSE).

Copyright © The OpenSTF Project. All Rights Reserved.
