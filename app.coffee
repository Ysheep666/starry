# Web 应用
path = require 'path'
config = require 'config'
express = require 'express'
passport = require 'passport'

{setting, db, mailer} = config
setting.root = path.normalize __dirname

global.adou = {}
adou.setting = setting

app = express()

require('./libs/mongodb') db
require('./libs/passport') passport
require('./libs/express') app, passport, setting, db
require('./libs/mailer') setting, db
require('./libs/events') setting
require('./starry/routes') app, setting

module.exports = app
