# 用户 Models
crypto = require 'crypto'
mongoose = require 'mongoose'

# 结构
UserSchema = new mongoose.Schema
  name: { type: String, required: true } # 名称
  email: { type: String, required: true, index: true } # 电子邮件地址
  salt: { type: String, default: '' } # 盐
  hashed_password: { type: String } # 哈希密码
  active: { type: Boolean, default: false } # 是否已激活
  verify_code: { type: String } # 验证 code

# 集合名称
UserSchema.set 'collection', 'users'

# 虚拟变量
UserSchema.virtual('password').set (password) ->
  @_password = password
  @salt = @makeSalt()
  @hashed_password = @encryptPassword password
.get ->
  return @_password

# 方法
UserSchema.methods =
  # 验证密码
  authenticate: (plainText) ->
    return @hashed_password is @encryptPassword plainText

  # 生成盐
  makeSalt: ->
    return '' + Math.round new Date().valueOf() * Math.random()

  # 密码加密
  encryptPassword: (password) ->
    return '' if not password

    try
      return crypto.createHmac('sha1', @salt).update(password).digest 'hex'
    catch err
      return ''

# 序列化结果
UserSchema.set 'toJSON',
  virtuals: true
  transform: (doc, ret) ->
    delete ret._id
    delete ret.__v
    return ret

module.exports = mongoose.model 'User', UserSchema
