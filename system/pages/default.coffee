# 默认 Page
async = require 'async'
router = require('express').Router()

User = require '../models/user'

# 首页
router.route('/').get (req, res) ->
  return res.redirect '/stories' if req.user
  res.render 'default/welcome'

# 登录
router.route('/signin').get (req, res) ->
  return res.redirect '/' if req.user
  res.render 'default/signin'

# 注册
router.route('/signup').get (req, res) ->
  return res.redirect '/' if req.user
  res.render 'default/signup'

# 忘记密码
router.route('/forgot').get (req, res) ->
  return res.redirect '/' if req.user
  res.render 'default/forgot'

# 邮箱验证
router.route(/^\/verify\/([0-9a-zA-z]+\.[0-9a-fA-F]+)$/).get (req, res, done) ->
  async.waterfall [
    (fn) ->
      User.findOne { verify_code: req.params[0] }, 'email', fn
    (user, fn) ->
      return fn null, null if not user
      user.active = true
      user.verify_code = ''
      user.save (err) -> fn err, user
  ], (err, user) ->
    return done err if err
    res.render 'default/verify', user: user

module.exports = router
