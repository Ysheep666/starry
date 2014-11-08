async = require 'async'
router = require('express').Router()

User = require '../models/user'

# 邮箱验证
router.route(/^\/verify\/([0-9a-zA-z]+\.[0-9a-fA-F]+)$/).get (req, res, done) ->
  async.waterfall [
    (fn) ->
      User.findOne
        verify_code: req.params[0]
      ,
        fields:
          email: 1
      , fn
    (user, fn) ->
      return fn null, null if not user
      User.update
        _id: user._id
      ,
        $set:
          active: true
          verify_code: ''
      , (err) ->
        fn err, user
  ], (err, user) ->
    return done err if err
    return res.render 'verify', user: user

module.exports = router
