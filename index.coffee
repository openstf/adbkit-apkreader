Path = require 'path'

module.exports = switch Path.extname __filename
  when '.coffee' then require './src/apkreader'
  else require './lib/apkreader'
