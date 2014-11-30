# 帐户 Page
router = require('express').Router()

# 登录
router.route('/signin').get (req, res) ->
  return res.redirect '/' if req.user
  res.render 'account/signin'

# 注册
router.route('/signup').get (req, res) ->
  return res.redirect '/' if req.user
  res.render 'account/signup'

# 忘记密码
router.route('/forgot').get (req, res) ->
  return res.redirect '/' if req.user
  res.render 'account/forgot'

module.exports = router
