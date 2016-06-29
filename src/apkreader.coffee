Zip = require 'adm-zip'

ManifestParser = require './apkreader/parser/manifest'
BinaryXmlParser = require './apkreader/parser/binaryxml'

class ApkReader
  MANIFEST = 'AndroidManifest.xml'
  REGEX = new RegExp('^lib/([^/]+)/')

  @readFile: (apk) ->
    new ApkReader apk

  constructor: (@apk) ->
    try
      @zip = new Zip @apk
    catch err
      if typeof err is 'string'
        throw new Error err
      else
        throw err

  readManifestSync: ->
    if manifest = @zip.getEntry MANIFEST
      new ManifestParser(manifest.getData()).parse()
    else
      throw new Error "APK does not contain '#{MANIFEST}'"

  readXmlSync: (path) ->
    if file = @zip.getEntry path
      new BinaryXmlParser(file.getData()).parse()
    else
      throw new Error "APK does not contain '#{path}'"

  readArchitectureInfo: ->
      list = @zip.getEntries()
      arcs = list.reduce(((arcs, entry) ->
        arch = REGEX.exec(entry.entryName)
        if arch and arch[1] and arcs.indexOf(arch[1]) == -1
          arcs.push arch[1]
        arcs
      ), [])
      arcs


module.exports = ApkReader
