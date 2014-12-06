gulp = require 'gulp'

# 加载插件
plugins = require('gulp-load-plugins')()
process.env.NODE_ENV = 'development' if not process.env.NODE_ENV

# error hander
handler = (err) ->
  plugins.util.beep()
  plugins.util.log plugins.util.colors.red(err.name), err.message

# Env development
gulp.task 'development-env', (callback) ->
  process.env.NODE_ENV = 'development'
  callback()

# Env test
gulp.task 'test-env', (callback) ->
  process.env.NODE_ENV = 'test'
  callback()

# Env production
gulp.task 'production-env', (callback) ->
  process.env.NODE_ENV = 'production'
  callback()

# Clean
gulp.task 'clean', (callback) ->
  del = require 'del'
  del ['.tmp', 'dist'], callback

# Create Setting
gulp.task 'create-setting', (callback) ->
  buckets = {}
  config = require './libs/config'

  {setting, upyun} = config

  for bucket in upyun.buckets
    buckets[bucket.name] = bucket.url

  adou = JSON.stringify
    title: setting.title
    description: setting.description
    upyun:
      api: upyun.api
      buckets: buckets

  src = require('stream').Readable objectMode: true
  src._read = ->
    @push new plugins.util.File cwd: '', base: '', path: 'setting.js', contents: new Buffer "var adou = #{adou};"
    @push null
  return src.pipe gulp.dest '.tmp/public/scripts'

# Lint
gulp.task 'lint', ->
  return gulp.src ['libs/**/*.coffee', 'starry/**/*.coffee', 'public/scripts/**/*.coffee']
    .pipe plugins.coffeelint()
    .pipe plugins.coffeelint.reporter()

# Font
gulp.task 'fonts', ->
  gulp.src 'public/components/font-awesome/**/*.{eot,svg,ttf,woff}'
    .pipe gulp.dest '.tmp/public'
    .pipe plugins.size()
  return

# Style
gulp.task 'styles', ->
  gulp.src 'public/styles/pages/**/*.less'
    .pipe plugins.plumber errorHandler: handler
    .pipe plugins.less
      dumpLineNumbers: 'comments'
    .pipe plugins.autoprefixer 'last 2 version', 'safari 5', 'ie 9', 'opera 12.1', 'ios 6', 'android 4'
    .pipe plugins.plumber.stop()
    .pipe gulp.dest '.tmp/public/styles'
    .pipe plugins.size()
  return

# Script
gulp.task 'scripts', ['create-setting'], ->
  gulp.src 'public/scripts/pages/**/*.coffee', { read: false }
    .pipe plugins.plumber errorHandler: handler
    .pipe plugins.browserify
      debug: true
      extensions: ['.hbs', '.coffee']
    .pipe plugins.rename
      extname: '.js'
    .pipe plugins.plumber.stop()
    .pipe gulp.dest '.tmp/public/scripts'
    .pipe plugins.size()
  return

# Watch
gulp.task 'watch', ->
  plugins.watch 'public/styles/**/*.less', (files, ccallback) ->
    gulp.start 'styles', ccallback
  plugins.watch 'public/scripts/**/*.{hbs,coffee}', (files, ccallback) ->
    gulp.start 'scripts', ccallback
  return

# Serve
gulp.task 'serve', ->
  return plugins.nodemon
    script: 'server.coffee'
    ext: 'coffee'
    ignore: [
      'gulpfile.coffee'
      '.tmp/**'
      'dist/**'
      'node_modules/**'
      'docs/**'
      'public/**'
      'tasks/**'
      'test/**'
      'commands/**'
    ]
  .on 'change', ['lint']
  .on 'restart', -> console.log 'restarted!'

# Develop
gulp.task 'develop', ['development-env', 'clean', 'lint'], ->
  gulp.start 'fonts', 'styles', 'scripts', 'watch', 'serve'

# Fixture
gulp.task 'fixture', (callback) ->
  fixture = require 'easy-fixture'
  MongoFixture = require 'easy-mongo-fixture'

  mongoFixture = new MongoFixture
    database: 'starry-test'
    collections: ['users', 'stories', 'sections', 'points']
    dir: 'test/fixtures'
    override: true

  fixture.use mongoFixture
  fixture.load().done -> callback()

# Test
gulp.task 'test', ['test-env', 'fixture'], ->
  return gulp.src 'test/**/*.coffee'
    .pipe plugins.mocha
      reporter: 'spec'
      timeout: 3000
      globals:
        should: require 'should'
    .once 'end', ->
      process.exit()

# Build assets
gulp.task 'build-assets', ->
  return gulp.src ['public/*.{ico,png,txt,xml}', 'public/components/font-awesome/**/*.{eot,svg,ttf,woff}']
    .pipe gulp.dest 'dist/public'
    .pipe plugins.size()

# Build style
gulp.task 'build-styles', ->
  return gulp.src 'public/styles/pages/**/*.less'
    .pipe plugins.less()
    .pipe plugins.autoprefixer 'last 2 version', 'safari 5', 'ie 9', 'opera 12.1', 'ios 6', 'android 4'
    .pipe gulp.dest '.tmp/public/styles'
    .pipe plugins.size()

# Build script
gulp.task 'build-scripts', ['create-setting'], ->
  return gulp.src 'public/scripts/pages/**/*.coffee', { read: false }
    .pipe plugins.browserify
      extensions: ['.hbs', '.coffee']
    .pipe plugins.rename
      extname: '.js'
    .pipe gulp.dest '.tmp/public/scripts'
    .pipe plugins.size()

# Build image
gulp.task 'build-images', ->
  return gulp.src('public/images/**/*')
    .pipe plugins.imagemin
      optimizationLevel: 3
      progressive: true
      interlaced: true
    .pipe gulp.dest 'dist/public/images'
    .pipe plugins.size()

# Html
gulp.task 'html', ['build-assets', 'build-styles', 'build-scripts', 'build-images'], ->
  assets = plugins.useref.assets searchPath: '{.tmp/public,public}'

  return gulp.src 'views/**/*.html'
    .pipe assets
    .pipe plugins.if '*.css', plugins.csso()
    .pipe plugins.if '*.js', plugins.uglify()
    .pipe plugins.rev()
    .pipe assets.restore()
    .pipe plugins.useref()
    .pipe plugins.revReplace()
    .pipe plugins.if '*.html', plugins.minifyHtml()
    .pipe plugins.if '*.css', gulp.dest 'dist/public'
    .pipe plugins.if '*.js', gulp.dest 'dist/public'
    .pipe plugins.if '*.html', gulp.dest 'dist/views'
    .pipe plugins.size()

# Templates
gulp.task 'templates', ['html'], ->
  return gulp.src 'dist/views/**/*.html'
    .pipe plugins.replace /((href|src){1}=["']?)(\/(images|styles|scripts){1}[^'">]*["']?)/ig, '$1{{ app.static_url }}$3'
    .pipe gulp.dest 'dist/views/'

# Build
gulp.task 'build', ['production-env', 'clean', 'lint'], ->
  gulp.start 'templates'

# Default
gulp.task 'default', ['develop']
