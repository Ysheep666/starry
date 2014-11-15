# 故事 Page
async = require 'async'
router = require('express').Router()

User = require '../models/user'

# 权限过滤
router.route('/*').get (req, res, done) ->
  return res.redirect '/signin' if not req.user
  done()

# 列表
router.route('/').get (req, res) ->
  res.send '12'

# 设计
router.route(/^\/([0-9a-fA-F]{24})$/).get (req, res) ->
  console.log req.params[0]
  res.render 'story/design'

module.exports = router
