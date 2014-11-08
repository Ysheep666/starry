# express 配置
path = require 'path'
express = require 'express'

module.exports = (app, config, passport) ->
  # 网络传输数据压缩
  app.use require('compression')()

  # 模板
  swig = require 'swig'
  app.engine 'html', swig.renderFile
  app.set 'view engine', 'html'

  # icon
  app.use require('serve-favicon')(path.join(config.app.root, 'public', 'favicon.ico'))

  # 开发环境
  if 'development' is app.get('env')
    app.use express.static(path.join(config.app.root, '.tmp', 'public'))
    app.use express.static(path.join(config.app.root, 'public'))

    app.use require('morgan')('short')

    app.set 'views', path.join(config.app.root, 'views')
    app.set 'view cache', false
    swig.setDefaults cache: false

  # 测试环境
  if 'test' is app.get('env')
    app.set 'views', path.join(config.app.root, 'views')

  # 生产环境
  if 'production' is app.get('env')
    app.use express.static(path.join(config.app.root, 'dist', 'public'),  maxAge: 365 * 24 * 3600)

    app.enable 'view cache'
    app.set 'views', path.join(config.app.root, 'dist', 'views')

  bodyParser = require 'body-parser'
  app.use bodyParser.urlencoded(extended: true)
  app.use bodyParser.json(type: 'json')

  app.use require('method-override')()
  app.use require('express-validator')()

  # cookie 和 session
  app.use require('cookie-parser')(config.app.secret)
  session = require 'express-session'
  app.use session(
    name: 'session.id'
    secret: config.app.secret
    cookie:
      path: '/'
      httpOnly: true
      maxAge: 1000 * 60 * 60 * 24 * 30 * 12
    store: new (require('connect-redis')(session))
      host: config.db.redis.host
      prefix: 'session:'
    resave: true
    saveUninitialized: true
  )

  # 防 csrf 攻击
  app.use require('csurf')() if 'test' isnt app.get('env')

  app.use passport.initialize()
  app.use passport.session()

  app.use (req, res, done) ->
    res.cookie '_csrf', req.csrfToken() if 'test' isnt app.get('env')

    cfgString = JSON.stringify
      config:
        title: config.app.title
        description: config.app.description

    res.locals.app = config.app
    res.locals.user = req.user
    res.locals.configScript = "<script>var adou = #{cfgString};</script>"
    done()
