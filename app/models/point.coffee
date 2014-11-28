# 节点 Models
mongoose = require 'mongoose'
ObjectId = mongoose.Schema.ObjectId

# 结构
PointSchema = new mongoose.Schema
  title: { type: String, default: '' } # 标题
  description: { type: String, default: '' } # 描述
  bubble: { type: String } # 气泡
  link: { type: String } # 链接
  image: { type: String } # 图片

# 集合名称
PointSchema.set 'collection', 'points'

# 序列化结果
PointSchema.set 'toJSON',
  virtuals: true
  transform: (doc, ret) ->
    delete ret._id
    delete ret.__v
    return ret

module.exports = mongoose.model 'Point', PointSchema
