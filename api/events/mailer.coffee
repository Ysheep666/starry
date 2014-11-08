# 邮件发送
events = require 'events'
emitter = new events.EventEmitter

# 发送邮箱地址验证邮件
emitter.on 'send_email_verify', (user, callback = ()->) ->
  # TODO: Unfinished
  callback()

# 发送找回密码邮件
emitter.on 'send_back_password', (user, callback = ()->) ->
  # TODO: Unfinished
  callback()

module.exports = emitter
