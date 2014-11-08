_ = require 'lodash'
async = require 'async'
router = require('express').Router()

{ObjectID} = require 'mongodb'

User = require '../models/user'
Project = require '../models/project'

# 过滤器：未登录验证
router.route(['/', '/:id/members']).post (req, res, done) ->
  if not req.user
    return res.status(401).json
      error: '未登录，没有此权限'
  done()

# 创建项目
router.route('/').post (req, res, done) ->
  req.assert('name', '项目名称不能为空').notEmpty()

  errs = req.validationErrors()
  return done isValidation: true, errors: errs if errs

  {user} = req

  async.waterfall [
    (fn) ->
      Project.create
        name: req.body.name.trim()
        members: [
          user_id: user._id
          is_creator: true
        ]
      , fn
    (project, fn) ->
      return fn null, null if not project
      index = _.findIndex user.projects, (id) ->
        return project._id.equals id

      if index < 0
        user.projects.push project._id

      User.update
        _id: user._id
      ,
        $set:
          projects: user.projects
      , (err) ->
        fn err, project
  ], (err, project) ->
    return done err if err
    res.status(201).json project

# 过滤器：该项目是否存在
router.route(/^\/([0-9a-fA-F]{24}).*$/).post (req, res, done) ->
  id = new ObjectID req.params[0]

  # 权限验证
  Project.findOne
    _id: id
  ,
    name: 1
    members: 1
  , (err, project) ->
    return done err if err

    if not project
      return res.status(404).json
        error: '该项目不存在'

    req.body.project = project
    done()

# 添加成员
router.route('/:id/members').post (req, res, done) ->
  {project} = req.body

  index = _.findIndex project.members, (member) ->
    return member.user_id.equals(req.user._id) and member.is_creator is true

  if index < 0
    return res.status(404).json
      error: '您不是该项目创始人，没有此权限'

  for member in req.body.members
    index = _.findIndex project.members, (m) ->
      return m.user_id.equals member

    if index < 0
      project.members.push
        user_id: new ObjectID member
        is_creator: false

  Project.update
    _id: project._id
  ,
    $set:
      members: project.members
  , (err) ->
    return fn err if err
    res.status(201).json project

module.exports = router
