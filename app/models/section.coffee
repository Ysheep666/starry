# 片段 Models
mongoose = require 'mongoose'
ObjectId = mongoose.Schema.ObjectId

# 结构
SectionSchema = new mongoose.Schema
  title: { type: String, default: '' } # 标题
  points: [{ type: ObjectId, ref: 'Point' }] # 节点

# 集合名称
SectionSchema.set 'collection', 'sections'

# 序列化结果
SectionSchema.set 'toJSON',
  virtuals: true
  transform: (doc, ret) ->
    delete ret._id
    delete ret.__v
    return ret

module.exports = mongoose.model 'Section', SectionSchema
