# 项目 Models
module.exports =
  collectionName: 'projects'

  # 创建项目
  # project
  #   name 名称
  #   members 成员
  #     user_id 用户 ID
  #     is_creator 是否是创建者
  # callback 回调函数
  create: (project, callback) ->
    {name, members} = project

    adou.getDatabase().create @collectionName,
      name: name # 名称
      members: members # 成员
      details: {} # 详情
    , (err, user) ->
      callback err, user

  # 更新项目
  # query 条件
  # doc 更新文档
  # callback 回调函数
  update: (query, doc, callback) ->
    adou.getDatabase().update @collectionName, query, doc, (err, result) ->
      callback err, result

  # 查找项目
  # query 条件
  # options 选项
  # callback 回调函数
  find: (query, options, callback) ->
    if typeof options is 'function'
      callback = options
      options =
        fields:
          name: 1

    adou.getDatabase().find @collectionName, query, options, callback

  # 查找单个项目
  # query 条件
  # options 选项
  # callback 回调函数
  findOne: (query, options, callback) ->
    if typeof options is 'function'
      callback = options
      options =
        fields:
          name: 1

    adou.getDatabase().findOne @collectionName, query, options, callback
