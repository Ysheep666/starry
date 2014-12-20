# 故事 Api
async = require 'async'
validator = require 'validator'
router = require('express').Router()

Story = require '../models/story'
Section = require '../models/section'
Point = require '../models/point'

# 权限过滤
router.route('/*').get (req, res, done) ->
  if not req.user
    return res.status(401).json
      error: '未登录，没有此权限'
  done()

# 新建
router.route('/').post (req, res, done) ->
  async.waterfall [
    (fn) ->
      section = new Section name: ''
      section.save (err, section) -> fn err, section
    (section, fn) ->
      story = new Story
        author: req.user.id
        sections: [ section.id ]

      story.save (err, story) -> fn err, story
  ], (err, story) ->
    return done err if err
    res.status(201).json id: story.id

# 删除故事
router.route(/^\/([0-9a-fA-F]{24})$/).delete (req, res, done) ->
  async.waterfall [
    (fn) ->
      Story.findById req.params[0], 'title', fn
    (story, fn) ->
      fn null, null if story.author isnt req.user.id
      story.remove (err) -> fn err, story
  ], (err, story) ->
    return done err if err
    return done() if not story
    res.status(202).json id: story.id

# 更新故事
router.route(/^\/([0-9a-fA-F]{24})$/).patch (req, res, done) ->
  { background, cover, theme, sections } = req.body

  req.assert('background', '背景地址格式不正确').isURL() if background
  req.assert('cover', '封面地址格式不正确').isURL() if cover
  req.assert('theme', '主题格式不正确').isAlpha() if theme

  errs = req.validationErrors()
  return done isValidation: true, errors: errs if errs

  async.waterfall [
    (fn) ->
      Story.findById req.params[0], 'background cover theme sections', fn
    (story, fn) ->
      fn null, null if story.author isnt req.user.id
      story.background = background if background
      story.cover = cover if cover
      story.theme = theme if theme
      story.sections = sections if sections
      story.save (err) -> fn err, story
  ], (err, story) ->
    return done err if err
    return done() if not story
    res.status(202).json story

# 更新故事简介
router.route(/^\/([0-9a-fA-F]{24})$/).post (req, res, done) ->
  req.assert('title', '标题不能为空').notEmpty()
  req.assert('mark', '标识不能为空').notEmpty()
  req.assert('mark', '标识格式不正确').matches /^[a-zA-Z0-9\-\.]+$/

  errs = req.validationErrors()
  return done isValidation: true, errors: errs if errs
  done()
.post (req, res, done) ->
  mark = req.body.mark.trim()
  Story.count { mark: mark, _id: $ne: req.params[0] }, (err, count) ->
    if 0 < count
      return done isValidation: true, errors: [
        param: 'mark'
        msg: '该标识已经被使用'
        value: mark
      ]
    done()
.post (req, res, done) ->
  async.waterfall [
    (fn) ->
      Story.findById req.params[0], 'title description mark', fn
    (story, fn) ->
      fn null, null if story.author isnt req.user.id
      story.title = req.sanitize('title').escape()
      story.description = req.sanitize('description').escape()
      story.mark = req.body.mark.trim().toLowerCase()
      story.save (err) -> fn err, story
  ], (err, story) ->
    return done err if err
    return done() if not story
    res.status(202).json story

# 新建故事片段
router.route(/^\/([0-9a-fA-F]{24})\/sections$/).post (req, res, done) ->
  req.assert('title', '标题不能为空').notEmpty()

  errs = req.validationErrors()
  return done isValidation: true, errors: errs if errs

  async.waterfall [
    (fn) ->
      section = new Section title: req.sanitize('title').escape()
      section.save (err, section) -> fn err, section
    (section, fn) ->
      Story.findById req.params[0], 'sections', (err, story) -> fn err, story, section
    (story, section, fn) ->
      fn null, null if story.author isnt req.user.id
      beforeIndex = if req.body.before then 1 + story.sections.indexOf req.body.before else 0
      story.sections.splice beforeIndex, 0, section.id
      story.save (err) -> fn err, section
  ], (err, section) ->
    return done err if err
    return done() if not story
    res.status(201).json section

# 删除故事片段
router.route(/^\/([0-9a-fA-F]{24})\/sections\/([0-9a-fA-F]{24})$/).delete (req, res, done) ->
  async.waterfall [
    (fn) ->
      Story.findById req.params[0], 'sections', fn
    (story, fn) ->
      fn null, null if story.author isnt req.user.id
      id = req.params[1]
      index = story.sections.indexOf id
      story.sections.splice index, 1
      story.save (err) -> fn err, id: id
  ], (err, section) ->
    return done err if err
    return done() if not story
    res.status(202).json id: section.id

# 列表
router.route('/').get (req, res) ->
  Story.find { author: req.user.id }, 'title cover', { sort: _id: -1 }, (err, stories) ->
    return done err if err
    res.status(200).json stories

# 详情
router.route(/^\/([0-9a-fA-F]{24})$/).get (req, res) ->
  async.waterfall [
    (fn) ->
      Story.findById req.params[0], 'title description mark background cover theme sections'
      .populate 'sections'
      .exec (err, story) -> fn err, story
    (story, fn) ->
      return fn null, null if not story
      Point.populate story.sections, { path: 'points' }, (err, points) ->
        story.sections.points = points
        fn err, story
  ], (err, story) ->
    return done err if err
    res.status(200).json story

module.exports = router
