app = require './app'
port = process.env.APP_PORT || 5000

app.listen port, ->
  console.log "qiukela application listening on port #{port}"

# 容错处理
process.on 'uncaughtException', (exc) -> console.error exc if 'production' is process.env.NODE_ENV
