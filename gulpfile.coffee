gulp = require 'gulp'

# 加载插件
plugins = require('gulp-load-plugins')()
process.env.ENV = 'development' if not process.env.ENV

# Clean
gulp.task 'clean', (callback) ->
  del = require 'del'
  del ['.tmp', 'dist'], callback

# Style
gulp.task 'styles', ->
  return gulp.src 'public/styles/pages/**/*.less'
    .pipe plugins.less
      dumpLineNumbers: 'comments'
    .pipe plugins.autoprefixer 'last 2 version', 'safari 5', 'ie 9', 'opera 12.1', 'ios 6', 'android 4'
    .pipe gulp.dest '.tmp/public/styles'
    .pipe plugins.size()

# Lint
gulp.task 'lint', ->
  return gulp.src ['libs/**/*.coffee', 'starry/**/*.coffee', 'public/scripts/**/*.coffee']
    .pipe plugins.coffeelint()
    .pipe plugins.coffeelint.reporter()

# Script
gulp.task 'scripts', ->
  return gulp.src 'public/scripts/pages/**/*.coffee', { read: false }
    .pipe plugins.browserify
      debug: 'production' isnt process.env.ENV
      extensions: ['.hbs', '.coffee']
    .pipe plugins.rename
      extname: '.js'
    .pipe gulp.dest '.tmp/public/scripts'
    .pipe plugins.size()

# Image
gulp.task 'images', ->
  return gulp.src('public/images/**/*')
    .pipe plugins.imagemin
      optimizationLevel: 3
      progressive: true
      interlaced: true
    .pipe gulp.dest 'dist/public/images'
    .pipe plugins.size()

# Html
gulp.task 'html', ['styles', 'lint', 'scripts'], ->
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

# Watch
gulp.task 'watch', ->
  gulp.watch 'public/styles/**/*.less', ['styles']
  gulp.watch 'public/scripts/**/*.{hbs,coffee}', ['lint', 'scripts']

# Fixture
gulp.task 'fixture', (callback) ->
  fixture = require 'easy-fixture'
  MongoFixture = require 'easy-mongo-fixture'

  mongoFixture = new MongoFixture
    database: 'starry-test'
    collections: ['users', 'folders', 'projects']
    dir: 'test/fixtures'
    override: true

  fixture.use mongoFixture
  fixture.save().done -> callback()

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
  .on 'change', ['coffeeLint']
  .on 'restart', -> console.log 'restarted!'

# Develop
gulp.task 'develop', ['clean'], ->
  gulp.start 'styles', 'lint', 'scripts', 'watch', 'serve'

# Build
gulp.task 'build', ['clean'], ->
  gulp.start 'images', 'html'


gulp.task 'default', ['develop']
