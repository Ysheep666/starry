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

# 新建
router.route('/').post (req, res) ->
  Story.create { user_id: new require('mongodb').ObjectID req.user._id }, (err, story) ->
    return done err if err

    delete story.sections
    res.status(200).json story

# 删除故事
router.route(/^\/([0-9a-fA-F]{24})$/).delete (req, res, done) ->
  Story.remove { _id: new require('mongodb').ObjectID req.params[0] }, (err) ->
    return done err if err
    res.status(200).json success: '删除故事成功'

# 更新故事
router.route(/^\/([0-9a-fA-F]{24})$/).patch (req, res, done) ->
  {background, cover, theme} = req.body

  req.assert('background', '背景地址格式不正确').isURL() if background
  req.assert('cover', '封面地址格式不正确').isURL() if cover
  req.assert('theme', '主题格式不正确').isAlpha() if theme

  errs = req.validationErrors()
  return done isValidation: true, errors: errs if errs

  details = {}
  details.background = background if background
  details.cover = cover if cover
  details.theme = theme if theme

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

# 更新故事简介
router.route(/^\/([0-9a-fA-F]{24})$/).post (req, res, done) ->
  req.assert('title', '标题不能为空').notEmpty()
  req.assert('mark', '标识不能为空').notEmpty()
  req.assert('mark', '标识格式不正确').matches /^[a-zA-Z0-9\-\.]+$/

  errs = req.validationErrors()
  return done isValidation: true, errors: errs if errs
  done()
.post (req, res, done) ->
  _id = new require('mongodb').ObjectID req.params[0]
  mark = req.body.mark.trim()

  Story.count { mark: mark, _id: $ne: _id  }, (err, count) ->
    if 0 < count
      return done isValidation: true, errors: [
        param: 'mark'
        msg: '该标识已经被使用'
        value: mark
      ]
    done()
.post (req, res, done) ->
  _id = new require('mongodb').ObjectID req.params[0]

  {title, description, mark} = req.body

  details = {}
  details.title = req.sanitize('title').escape()
  details.description = req.sanitize('description').escape()
  details.mark = mark.trim()

  async.waterfall [
    (fn) ->
      Story.update { _id: _id }, $set: details, fn
    (result, fn) ->
      Story.findOne { _id: _id }, fn
  ], (err, story) ->
    return done err if err

    delete story.sections
    res.status(200).json story

# 列表
router.route('/').get (req, res) ->
  Story.find { user_id: req.user._id }, {sort: _id: -1}, (err, stories) ->
    return done err if err
    res.status(200).json stories

# 详情
router.route(/^\/([0-9a-fA-F]{24})$/).get (req, res) ->
  Story.findOne { _id: new require('mongodb').ObjectID req.params[0] }, (err, story) ->
    return done err if err
    res.status(200).json story

module.exports = router
