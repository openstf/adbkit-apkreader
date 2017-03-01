Zip = require 'yauzl'
Promise = require 'bluebird'

ManifestParser = require './apkreader/parser/manifest'
BinaryXmlParser = require './apkreader/parser/binaryxml'

class ApkReader
  MANIFEST = 'AndroidManifest.xml'

  @open: (apk) ->
    Promise.resolve new ApkReader apk

  constructor: (@apk) ->

  _open: ->
    Promise.fromCallback (callback) =>
      Zip.open @apk, lazyEntries: true, callback

  usingFile: (file, action) ->
    this.usingFileStream file, (stream) ->
      endListener = errorListener = readableListener = undefined
      new Promise (resolve, reject) ->
        chunks = []
        totalLength = 0
        tryRead = ->
          while chunk = stream.read()
            chunks.push chunk
            totalLength += chunk.length
          return
        stream.on 'readable', readableListener = -> tryRead()
        stream.on 'error', errorListener = (err) -> reject err
        stream.on 'end', endListener = -> resolve Buffer.concat(chunks, totalLength)
      .then action
      .finally ->
        stream.removeListener 'readable', readableListener
        stream.removeListener 'error', errorListener
        stream.removeListener 'end', endListener

  usingFileStream: (file, action) ->
    this._open().then (zipfile) ->
      endListener = errorListener = entryListener = undefined
      new Promise (resolve, reject) ->
        zipfile.on 'entry', entryListener = (entry) ->
          if entry.fileName is file
            resolve Promise.fromCallback (callback) ->
              zipfile.openReadStream entry, callback
          else
            zipfile.readEntry()
        zipfile.on 'end', endListener = ->
          reject new Error "APK does not contain '#{file}'"
        zipfile.on 'error', errorListener = (err) -> reject err
        zipfile.readEntry()
      .then action
      .finally ->
        zipfile.removeListener 'entry', entryListener
        zipfile.removeListener 'error', errorListener
        zipfile.removeListener 'end', endListener
        zipfile.close()
        
  readContent: (path) ->
    this.usingFile path, (content) -> content

  readManifest: ->
    this.usingFile MANIFEST, (content) ->
      new ManifestParser(content).parse()
      
  readManifestContent: ->
    this.usingFile MANIFEST, (content) -> content

  readXml: (path) ->
    this.usingFile path, (content) ->
      new BinaryXmlParser(content).parse()

module.exports = ApkReader
