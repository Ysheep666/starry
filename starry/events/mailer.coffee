# 邮件发送
events = require 'events'
emitter = new events.EventEmitter

# 邮箱地址验证邮件
emitter.on 'email_verify', (user, callback) ->
  # TODO: Unfinished
  callback() if callback

# 找回密码邮件
emitter.on 'back_password', (user, callback) ->
  # TODO: Unfinished
  callback() if callback

module.exports = emitter
