# 章节 Models
module.exports =
  collectionName: 'sections'

  # 创建章节
  # project
  #   name 名称
  # callback 回调函数
  create: (section, callback) ->
    {name} = section

    adou.getDatabase().create @collectionName,
      name: name # 名称
      points: [] # 内容点
    , callback

  # 更新章节
  # query 条件
  # doc 更新文档
  # callback 回调函数
  update: (query, doc, callback) ->
    adou.getDatabase().update @collectionName, query, doc, callback

  # 查找章节
  # query 条件
  # options 选项
  # callback 回调函数
  find: (query, options, callback) ->
    if typeof options is 'function'
      callback = options
      options =
        fields: { name: 1, points: 1 }

    adou.getDatabase().find @collectionName, query, options, callback

  # 查找单个章节
  # query 条件
  # options 选项
  # callback 回调函数
  findOne: (query, options, callback) ->
    if typeof options is 'function'
      callback = options
      options =
        fields: { name: 1, points: 1 }

    adou.getDatabase().findOne @collectionName, query, options, callback
