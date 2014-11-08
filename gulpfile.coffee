gulp = require 'gulp'

# 加载插件
plugins = require('gulp-load-plugins')()
process.env.ENV = 'development' if not process.env.ENV

# 样式
gulp.task 'styles', ->
  return gulp.src 'public/styles/*.less'
    .pipe plugins.recess()
    .pipe plugins.recess.reporter()
    .pipe plugins.less
      dumpLineNumbers: 'comments'
    .pipe plugins.autoprefixer 'last 1 version'
    .pipe gulp.dest '.tmp/public/styles'
    .pipe plugins.size()

# 脚本
gulp.task 'scripts', ->
  return gulp.src 'public/scripts/*.coffee', { read: false }
    .pipe plugins.browserify
      debug: 'production' isnt process.env.ENV
      extensions: ['.coffee']
    .pipe plugins.rename
      extname: '.js'
    .pipe gulp.dest '.tmp/public/scripts'
    .pipe plugins.size()
