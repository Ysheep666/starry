# 默认 Api
crypto = require 'crypto'
async = require 'async'
passport = require 'passport'
router = require('express').Router()

User = require '../models/user'

# 又拍云生成 signature 和 policy
router.route('/upyun_token').post (req, res) ->
  bucket = (b for b in adou.config.upyun.buckets when b.name is req.body.bucket.trim())[0]
  policy = new Buffer(JSON.stringify(req.body)).toString 'base64'
  signature = crypto.createHash('md5').update(policy + '&' + bucket.secret).digest 'hex'
  res.status(200).json policy: policy, signature: signature

# 注册
router.route('/signup').post (req, res, done) ->
  req.assert('name', '姓名不能为空').notEmpty()
  req.assert('email', '邮箱地址不能为空').notEmpty()
  req.assert('email', '邮箱地址格式不正确').isEmail()
  req.assert('password', '密码不能为空').notEmpty()

  errs = req.validationErrors()
  return done isValidation: true, errors: errs if errs

  done()
.post (req, res, done) ->
  email = req.body.email.trim()

  User.count { email: email }, (err, count) ->
    if 0 < count
      return done isValidation: true, errors: [
        param: 'email'
        msg: '该邮箱地址已经被使用'
        value: email
      ]
    done()
.post (req, res, done) ->
  req.sanitize('name').escape()

  user =
    name: req.body.name.trim()
    email: req.body.email.trim()
    password: req.body.password

  User.create user, (err, user) ->
    return done err if err

    # 发送邮箱地址验证邮件
    adou.getEmitter('mailer').emit 'email_verify', user

    # 并且登录
    req.logIn _id: user._id, (err) ->
      return done err if err
      res.status(201).json success: '注册成功'

# 找回密码
router.route('/forgot').post (req, res, done) ->
  req.assert('email', '邮箱地址不能为空').notEmpty()
  req.assert('email', '邮箱地址格式不正确').isEmail()

  errs = req.validationErrors()
  return done isValidation: true, errors: errs if errs

  async.waterfall [
    (fn) ->
      User.findOne { email: req.body.email.trim() }, fields: { login: 1, name: 1, email: 1, salt: 1 }, fn
    (user, fn) ->
      if not user
        return fn
          isValidation: true
          errors: [
            param: 'email'
            msg: '该邮箱地址不存在'
            value: email
          ]
        , null

      user.password = crypto.randomBytes(Math.ceil(6)).toString('hex').slice 0, 12

      User.update { _id: user._id}, $set: { hashed_password: User.encryptPassword user.password, user.salt } , (err) ->
        return fn err if err

        # 发送找回密码邮件
        adou.getEmitter('mailer').emit 'back_password', user

        fn null
  ], (err) ->
    return done err if err
    res.status(201).json success: '找回密码成功'

# 登录和退出账号
router.route('/signin').post (req, res, done) ->
  _logIn = (err, user) ->
    return done err if err
    return res.status(422).json error: '电子邮件地址或密码错误' if not user
    req.logIn user, (err) ->
      return done err if err
      res.status(201).json success: '登录成功'
  passport.authenticate('local', _logIn) req, res, done
.delete (req, res) ->
  req.logout()
  res.status(202).json success: '退出账号成功'

# 获取个人信息
router.route('/me').get (req, res) ->
  if not req.user
    return res.status(401).json
      error: '未登录，没有此权限'
  res.json req.user

module.exports = router
