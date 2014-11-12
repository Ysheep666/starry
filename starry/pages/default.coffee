async = require 'async'
router = require('express').Router()

User = require '../models/user'
Section = require '../models/section'

# 首页
router.route('/').get (req, res) ->
  return res.redirect '/aquarius' if req.user
  res.render 'default/welcome'

# 更新
router.route('/aquarius').get (req, res) ->
  return res.redirect '/signin' if not req.user

  {user} = req

  Section.find
    _id: $in: user.sections
  , (err, sections) ->
    return done err if err
    user.sections = sections
    res.render 'default/aquarius', user: user

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
      User.findOne
        verify_code: req.params[0]
      , fields: { email: 1 }, fn
    (user, fn) ->
      return fn null, null if not user
      User.update
        _id: user._id
      , $set: { active: true, verify_code: '' }, (err) ->
        fn err, user
  ], (err, user) ->
    return done err if err
    res.render 'default/verify', user: user

module.exports = router
