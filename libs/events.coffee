# 事件管理
path = require 'path'

module.exports = (setting) ->
  eventPath = path.join setting.root, 'starry', 'events'
  eventFiles = require('fs').readdirSync eventPath

  object = {}

  for file in eventFiles
    if file.slice(-7) is '.coffee'
      key = file.substr 0, file.length - 7
      object[key] = require path.join eventPath, file

  adou.emitter = (key) -> return object[key]
