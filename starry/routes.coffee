_ = require 'lodash'
express = require 'express'

module.exports = (app, setting) ->
  # 页面
  app.use require('./pages/default')

  app.use '/api/*', (req, res, done) ->
    res.contentType "application/vnd.#{setting.api_vnd}+json"
    done()

  # 接口
  app.use '/api/', require('./apis/default')

  # 错误处理
  app.use (err, req, res, done) ->
    return done err if not err.isValidation
    errs = _.uniq err.errors, (err) ->
      return err.param
    return res.status(400).json error: errs

  # 生产环境
  if 'production' is app.get('env')
    # 500 页面
    app.use (err, req, res, done) ->
      console.error err
      if req.xhr
        res.status(500).json error: '系统出错！'
      else
        res.status(500).render '500',
          title: 500

    # 404 页面
    app.use (req, res) ->
      console.warn "#{req.originalUrl} does not exist."
      if (req.xhr)
        res.status(404).json error: '请求地址不存在！'
      else
        res.status(404).render '404',
          title: 404
