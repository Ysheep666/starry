# MongoDB 管理
mongoose = require 'mongoose'

module.exports = (db) ->
  {url} = db.mongodb
  mongoose.connect url
  db = mongoose.connection
  db.on 'error', -> throw new Error "unable to connect to database at #{url}"
