# 登录认证
User = require '../system/models/user'

module.exports = (passport) ->
  passport.serializeUser (user, done) ->
    done null, user.id

  passport.deserializeUser (id, done) ->
    User.findById id, 'name email', done

  # Local
  passport.use new (require('passport-local').Strategy)(
    usernameField: 'email'
    passwordField: 'password'
  , (email, password, done) ->
    User.findOne { email: email }, 'name email salt hashed_password', (err, user) ->
      return done err if err
      return done null, false, message: '该用户不存在。' if not user
      return done null, false, message: '密码错误。' if not user.authenticate password
      return done null, user
  )
