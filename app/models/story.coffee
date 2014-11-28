# 故事 Models
mongoose = require 'mongoose'
ObjectId = mongoose.Schema.ObjectId

# 结构
StorySchema = new mongoose.Schema
  author: { type: ObjectId, ref: 'User'} # 作者
  title: { type: String, default: '' } # 标题
  description: { type: String, default: '' } # 描述
  mark: { type: String, index: true } # 标识
  background: { type: String } # 背景
  cover: { type: String } # 封面
  theme: { type: String, enum: [ 'black', 'gray', 'green', 'blue', 'pink', 'red' ], default: 'black' } # 主题
  sections: [{ type: ObjectId, ref: 'Section' }] # 片段

# 集合名称
StorySchema.set 'collection', 'stories'

# 序列化结果
StorySchema.set 'toJSON',
  virtuals: true
  transform: (doc, ret) ->
    delete ret._id
    delete ret.__v
    return ret

module.exports = mongoose.model 'Story', StorySchema
