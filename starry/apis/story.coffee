# 故事 Api
async = require 'async'
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
  Story.find { user_id: req.user._id }, {sort: _id: -1}, (err, stories) ->
    return done err if err
    res.status(200).json stories

# 新建
router.route('/').post (req, res) ->
  Story.create { user_id: new require('mongodb').ObjectID req.user._id }, (err, story) ->
    return done err if err

    delete story.sections

    res.status(200).json story

# 详情
router.route(/^\/([0-9a-fA-F]{24})$/).get (req, res) ->
  Story.findOne { _id: new require('mongodb').ObjectID req.params[0] }, (err, story) ->
    return done err if err
    res.status(200).json story

# 更新故事
router.route(/^\/([0-9a-fA-F]{24})$/).post (req, res, done) ->
  {title, mark, description, background, cover, theme} = req.body

  details = {}
  details.background = background if background and validator.isURL background
  details.cover = cover if cover and validator.isURL cover
  details.theme = theme if theme and validator.isAlpha theme

  if '{}' is JSON.stringify details
    return done()

  _id = new require('mongodb').ObjectID req.params[0]

  async.waterfall [
    (fn) ->
      Story.update { _id: _id }, $set: details, fn
    (result, fn) ->
      Story.findOne { _id: _id }, fn
  ], (err, story) ->
    return done err if err

    delete story.sections

    res.status(200).json story

module.exports = router
