Zip = require 'adm-zip'

ManifestParser = require './apkreader/parser/manifest'
BinaryXmlParser = require './apkreader/parser/binaryxml'

class ApkReader
  MANIFEST = 'AndroidManifest.xml'

  constructor: (@apk) ->
    @zip = new Zip @apk

  readManifest: ->
    if manifest = @zip.getEntry MANIFEST
      new ManifestParser(manifest.getData()).parse()
    else
      throw new Error "APK does not contain '#{MANIFEST}'"

  readXml: (path) ->
    if file = @zip.getEntry path
      new BinaryXmlParser(file.getData()).parse()
    else
      throw new Error "APK does not contain '#{path}'"

module.exports = ApkReader
