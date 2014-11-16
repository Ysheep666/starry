# 故事 Page
async = require 'async'
router = require('express').Router()

User = require '../models/user'
Story = require '../models/story'

# 权限过滤
router.route('/*').get (req, res, done) ->
  return res.redirect '/signin' if not req.user
  done()

# 列表
router.route('/').get (req, res, done) ->
  preloaded = {}
  Story.find { user_id: req.user._id }, (err, stories) ->
    return done err if err
    preloaded.stories = stories
    res.render 'story/default', preloaded: JSON.stringify preloaded

# 设计
router.route(/^\/([0-9a-fA-F]{24})$/).get (req, res) ->
  console.log req.params[0]
  res.render 'story/design2'

module.exports = router
