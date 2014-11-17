# 故事 Api
router = require('express').Router()

Story = require '../models/story'

# 权限过滤
router.route('/*').get (req, res, done) ->
  if not req.user
    return res.status(401).json
      error: '未登录，没有此权限'
  done()

# 列表
router.route('/').get (req, res) ->
  Story.find { user_id: req.user._id }, (err, stories) ->
    return done err if err
    res.status(200).json stories

module.exports = router
