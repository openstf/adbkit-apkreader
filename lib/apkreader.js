'use strict'

const Zip = require('yauzl')
const Promise = require('bluebird')

const ManifestParser = require('./apkreader/parser/manifest')
const BinaryXmlParser = require('./apkreader/parser/binaryxml')

class ApkReader {
  static open(apk) {
    return Promise.resolve(new ApkReader(apk))
  }

  constructor(apk) {
    this.apk = apk
  }

  _open() {
    return Promise.fromCallback(callback => {
      return Zip.open(this.apk, {lazyEntries: true}, callback)
    })
  }

  usingFile(file, action) {
    return this.usingFileStream(file, function(stream) {
      let errorListener, readableListener, endListener

      const read = () => new Promise(function(resolve, reject) {
        const chunks = []

        let totalLength = 0

        const tryRead = function() {
          let chunk
          while ((chunk = stream.read())) {
            chunks.push(chunk)
            totalLength += chunk.length
          }
        }

        readableListener = () => tryRead()
        errorListener = err => {
          stream.destroy()
          reject(err)
        }
        endListener = () => resolve(Buffer.concat(chunks, totalLength))

        stream.on('readable', readableListener)
        stream.on('error', errorListener)
        stream.on('end', endListener)

        tryRead()
      })

      return read().then(action).finally(function() {
        stream.removeListener('readable', readableListener)
        stream.removeListener('error', errorListener)
        stream.removeListener('end', endListener)
      })
    })
  }

  usingFileStream(file, action) {
    return this._open().then(function(zipfile) {
      let entryListener, errorListener, endListener

      const find = () => new Promise(function(resolve, reject) {
        entryListener = entry => {
          if (entry.fileName === file) {
            return resolve(Promise.fromCallback(callback => {
              zipfile.openReadStream(entry, callback)
            }))
          }

          zipfile.readEntry()
        }

        endListener = () => {
          reject(new Error(`APK does not contain '${file}'`))
        }

        errorListener = err => reject(err)

        zipfile.on('entry', entryListener)
        zipfile.on('end', endListener)
        zipfile.on('error', errorListener)

        zipfile.readEntry()
      })

      return find().then(action).finally(function() {
        zipfile.removeListener('entry', entryListener)
        zipfile.removeListener('error', errorListener)
        zipfile.removeListener('end', endListener)
        zipfile.close()
      })
    })
  }

  readContent(path) {
    return this.usingFile(path, content => content)
  }

  readManifest(options = {}) {
    return this.usingFile(ApkReader.MANIFEST, content => {
      return new ManifestParser(content, options).parse()
    })
  }

  readXml(path, options = {}) {
    return this.usingFile(path, content => {
      return new BinaryXmlParser(content, options).parse()
    })
  }
}

ApkReader.MANIFEST = 'AndroidManifest.xml'

module.exports = ApkReader
