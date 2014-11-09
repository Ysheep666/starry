# 登录认证
User = require '../starry/models/user'

module.exports = (passport) ->
  passport.serializeUser (user, done) ->
    done null, user._id

  passport.deserializeUser (id, done) ->
    User.findOne { _id: new require('mongodb').ObjectID id }, done

  # Local
  passport.use new (require('passport-local').Strategy)(
    usernameField: 'email'
    passwordField: 'password'
  , (email, password, done) ->
    User.findOne
      email: email
    , fields: { login: 1, name: 1, email: 1, salt: 1, hashed_password: 1 }, (err, user) ->
      return done err if err
      return done null, false, message: '该用户不存在。' if not user
      return done null, false, message: '密码错误。' if not User.authenticate password, user.salt, user.hashed_password
      return done null, user
  )
