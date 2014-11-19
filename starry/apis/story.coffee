# 故事 Api
validator = require 'validator'
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

# 详情
router.route(/^\/([0-9a-fA-F]{24})$/).get (req, res) ->
  Story.findOne { _id: new require('mongodb').ObjectID req.params[0] }, (err, story) ->
    return done err if err
    res.status(200).json story

# 更新信息
router.route(/^\/([0-9a-fA-F]{24})$/).post (req, res, done) ->
  {title, mark, description, background, cover, theme} = req.body

  details = {}
  details.background = background if background and validator.isURL background
  details.cover = cover if cover and validator.isURL cover
  details.theme = theme if theme and validator.isAlpha theme

  if '{}' is JSON.stringify details
    return done()

  Story.update { _id: new require('mongodb').ObjectID req.params[0] }, $set: details, (err) ->
    return done err if err
    res.status(200).json success: '更新信息成功'


module.exports = router
