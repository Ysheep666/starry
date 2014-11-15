# 用户 Models
crypto = require 'crypto'

module.exports =
  collectionName: 'users'

  # 验证密码
  authenticate: (password, salt, hashed_password) ->
    return hashed_password is @encryptPassword password, salt

  # 生成盐
  makeSalt: ->
    return '' + Math.round new Date().valueOf() * Math.random()

  # 密码加密
  encryptPassword: (password, salt = '') ->
    return '' if not password

    try
      return crypto.createHmac('sha1', salt).update(password).digest 'hex'
    catch err
      return ''

  # 创建用户
  # user
  #   name 姓名
  #   email 邮箱地址
  #   password 密码
  # callback 回调函数
  create: (user, callback) ->
    {name, email, password} = user

    salt = @makeSalt()
    hashed_password = @encryptPassword password, salt

    uniqid = new Date().getTime().toString(36)
    verify_code = uniqid + '.' + crypto.createHash('md5').update(email).digest 'hex'

    adou.getDatabase().create @collectionName,
      name: name # 姓名
      email: email # 邮件地址
      salt: salt # 盐
      hashed_password: hashed_password # 哈希密码
      active: false # 是否激活
      verify_code: verify_code # 验证 code
      details: {} # 详情
    , callback

  # 更新用户
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

  # 查找用户
  # query 条件
  # options 选项
  # callback 回调函数
  find: (query, options, callback) ->
    if typeof options is 'function'
      callback = options
      options =
        fields:
          fields: { name: 1, email: 1 }

    adou.getDatabase().find @collectionName, query, options, callback

  # 查找用户
  # query 条件
  # options 选项
  # callback 回调函数
  findOne: (query, options, callback) ->
    if typeof options is 'function'
      callback = options
      options =
        fields: { name: 1, email: 1, details: 1 }

    adou.getDatabase().findOne @collectionName, query, options, callback
