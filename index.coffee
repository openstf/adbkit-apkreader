Path = require 'path'

module.exports = switch Path.extname __filename
  when '.coffee' then require './src/apkutil'
  else require './lib/apkutil'
