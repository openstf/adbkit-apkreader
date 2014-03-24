gulp = require 'gulp'
clean = require 'gulp-clean'
coffee = require 'gulp-coffee'
mocha = require 'gulp-mocha'
jsonlint = require 'gulp-jsonlint'

gulp.task 'clean', ->
  gulp.src ['lib', 'index.js'], read: false
    .pipe clean()

gulp.task 'jsonlint', ->
  gulp.src '*.json'
    .pipe jsonlint()
    .pipe jsonlint.reporter()

gulp.task 'lint', ['jsonlint']

gulp.task 'compile-src', ->
  gulp.src 'src/**/*.coffee'
    .pipe coffee()
    .pipe gulp.dest 'lib'

gulp.task 'compile-main', ->
  gulp.src '*.coffee'
    .pipe coffee()
    .pipe gulp.dest '.'

gulp.task 'compile', ['compile-src', 'compile-main']

gulp.task 'mocha', ->
  gulp.src 'test/**/*.coffee', read: false
    .pipe mocha
      reporter: 'spec'

gulp.task 'test', ['lint', 'mocha']
gulp.task 'prepublish', ['test', 'compile']
gulp.task 'postpublish', ['clean']
gulp.task 'default', ['test']
