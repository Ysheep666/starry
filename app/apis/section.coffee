# 片段 Api
async = require 'async'
validator = require 'validator'
router = require('express').Router()

Section = require '../models/section'
Point = require '../models/point'

# 权限过滤
router.route('/*').get (req, res, done) ->
  if not req.user
    return res.status(401).json
      error: '未登录，没有此权限'
  done()

# 更新片段
router.route(/^\/([0-9a-fA-F]{24})$/).post (req, res, done) ->
  req.assert('title', '标题不能为空').notEmpty()

  errs = req.validationErrors()
  return done isValidation: true, errors: errs if errs

  async.waterfall [
    (fn) ->
      Section.findById req.params[0], 'title', fn
    (section, fn) ->
      section.title = req.sanitize('title').escape()
      section.save (err) -> fn err, section
  ], (err, section) ->
    return done err if err
    res.status(202).json section

# 新建故事节点
router.route(/^\/([0-9a-fA-F]{24})\/points$/).post (req, res, done) ->
  { bubble, link, image } = req.body

  req.assert('title', '标题不能为空').notEmpty()
  req.assert('link', '链接格式不正确').isURL() if link
  req.assert('image', '图片地址格式不正确').isURL() if image

  errs = req.validationErrors()
  return done isValidation: true, errors: errs if errs

  async.waterfall [
    (fn) ->
      point = new Point
        title: req.sanitize('title').escape()
        description: req.sanitize('description').escape()

      point.bubble = req.sanitize('bubble').escape() if bubble
      point.link = link if link
      point.image = image if image
      point.save (err, point) -> fn err, point
    (point, fn) ->
      Section.findById req.params[0], 'points', (err, section) -> fn err, section, point
    (section, point, fn) ->
      section.points.push point.id
      section.save (err) -> fn err, point
  ], (err, point) ->
    return done err if err
    res.status(201).json point

# 删除故事节点
router.route(/^\/([0-9a-fA-F]{24})\/points\/([0-9a-fA-F]{24})$/).delete (req, res, done) ->
  async.waterfall [
    (fn) ->
      Section.findById req.params[0], 'points', fn
    (section, fn) ->
      id = req.params[1]
      index = section.points.indexOf id
      section.points.splice index, 1
      section.save (err) -> fn err, id: id
  ], (err, point) ->
    return done err if err
    res.status(202).json id: point.id


module.exports = router
