# 故事 Models
crypto = require 'crypto'

module.exports =
  collectionName: 'stories'

  # 创建故事
  # story
  #   user_id 用户 id
  # callback 回调函数
  create: (story, callback) ->
    {user_id} = story

    adou.getDatabase().create @collectionName,
      user_id: user_id
      title: '' # 标题
      mark: '' # 标识
      description: '' #描述
      background: '' # 背景
      cover: '' # 封面
      theme: '' # 主题 ^_^: 'black', 'gray', 'green', 'blue', 'pink', 'red'
      sections: [] # 片段
    , callback

  # 删除故事
  # query 条件
  # callback 回调函数
  remove: (query, callback) ->
    adou.getDatabase().remove @collectionName, query, callback

  # 更新故事
  # query 条件
  # doc 更新文档
  # callback 回调函数
  update: (query, doc, callback) ->
    adou.getDatabase().update @collectionName, query, doc, callback

  # 统计
  # query 条件
  # callback 回调函数
  count: (query, callback) ->
    adou.getDatabase().count @collectionName, query, callback

  # 查找故事
  # query 条件
  # options 选项
  # callback 回调函数
  find: (query, options, callback) ->
    if typeof options is 'function'
      callback = options
      options =
        fields: { title: 1, cover: 1 }

    adou.getDatabase().find @collectionName, query, options, callback

  # 查找故事
  # query 条件
  # options 选项
  # callback 回调函数
  findOne: (query, options, callback) ->
    if typeof options is 'function'
      callback = options
      options =
        fields: { title: 1, mark: 1, description: 1, background: 1, cover: 1, theme: 1, sections: 1 }

    adou.getDatabase().findOne @collectionName, query, options, callback
