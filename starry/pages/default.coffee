router = require('express').Router()

# 首页
router.route('/').get (req, res) ->
  return res.redirect '/aquarius' if req.user
  res.render 'default/index'

module.exports = router
