router = require('express').Router()

# 首页
router.route('/').get (req, res) ->
  return res.redirect '/aquarius' if req.user
  res.render 'default'

# 登录 注册 忘记密码
router.route(['/signin', '/signup', '/forgot']).get (req, res) ->
  res.render 'account'

module.exports = router
