# 默认 Page
async = require 'async'
router = require('express').Router()

Story = require '../models/story'
Point = require '../models/point'

# 首页
router.route('/').get (req, res) ->
  return res.redirect '/stories' if req.user
  res.render 'default/default'

# 展示
router.route(/^\/\@(.+)$/).get (req, res, done) ->
  param = req.params[0]
  query = if /^[0-9a-fA-F]{24}$/.test param then {'$or': [{_id: param}, {mark: param}]} else mark: param
  async.waterfall [
    (fn) ->
      Story.findOne query, 'title description mark background cover theme sections'
      .populate 'sections'
      .exec (err, story) -> fn err, story
    (story, fn) ->
      return fn null, null if not story
      Point.populate story.sections, {path: 'points'}, (err, points) ->
        story.sections.points = points
        fn err, story
  ], (err, story) ->
    return done err if err
    return done() if not story
    res.render 'default/show', {story: story}

module.exports = router
