crypto = require 'crypto'
async = require 'async'
passport = require 'passport'
router = require('express').Router()

User = require '../models/user'
Project = require '../models/project'

# 获取个人信息
router.route('/me').get (req, res, done) ->
  if not req.user
    return res.status(401).json
      error: '未登录，没有此权限'

  {user} = req

  Project.find
    _id:
      $in: user.projects
  , (err, projects) ->
    user.projects = projects
    return res.json user

# 登录和退出账号
router.route('/signin').post (req, res, done) ->
  passport.authenticate('local', (err, user) ->
    return done err if err
    return res.status(422).json error: '电子邮件地址或密码错误' if not user
    req.logIn user, (err) ->
      return done err if err
      return res.status(201).json success: '登录成功'
  ) req, res, done
.delete (req, res) ->
  req.logout()
  return res.status(202).json success: '退出账号成功'

# 注册
router.route('/signup').post (req, res, done) ->
  req.assert('email', '邮箱地址不能为空').notEmpty()
  req.assert('email', '邮箱地址格式不正确').isEmail()
  req.assert('name', '名称不能为空').notEmpty()
  req.assert('password', '密码不能为空').notEmpty()

  errs = req.validationErrors()
  return done isValidation: true, errors: errs if errs

  email = req.body.email.trim()

  User.uniqueEmail email, (err, unique) ->
    if not unique
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
    adou.getEmitter('mailer').emit 'send_email_verify', user

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
      User.findOne
        email: req.body.email.trim()
      ,
        fields:
          name: 1
          email: 1
          salt: 1
      , fn
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

      User.update
        _id: user._id
      ,
        $set:
          hashed_password: User.encryptPassword user.password, user.salt
      , (err) ->
        return fn err if err

        # 发送找回密码邮件
        adou.getEmitter('mailer').emit 'send_back_password', user

        fn null
  ], (err) ->
    return done err if err
    res.status(201).json success: '找回密码成功'

module.exports = router
