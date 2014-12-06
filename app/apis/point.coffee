# 片段 Api
async = require 'async'
validator = require 'validator'
router = require('express').Router()

Point = require '../models/point'

# 权限过滤
router.route('/*').get (req, res, done) ->
  if not req.user
    return res.status(401).json
      error: '未登录，没有此权限'
  done()

# 更新节点
router.route(/^\/([0-9a-fA-F]{24})$/).post (req, res, done) ->
  { bubble, link, image } = req.body

  req.assert('title', '标题不能为空').notEmpty()
  req.assert('link', '链接格式不正确').isURL() if link && 0 isnt link.indexOf 'mailto:'
  req.assert('image', '图片地址格式不正确').isURL() if image

  errs = req.validationErrors()
  return done isValidation: true, errors: errs if errs

  async.waterfall [
    (fn) ->
      Point.findById req.params[0], 'title description bubble link image', fn
    (point, fn) ->
      point.title = req.sanitize('title').escape()
      point.description = req.sanitize('description').escape()
      point.bubble = bubble
      point.link = link
      point.image = image
      point.save (err) -> fn err, point
  ], (err, point) ->
    return done err if err
    res.status(202).json point

module.exports = router
