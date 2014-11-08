# Web 应用
express = require 'express'
passport = require 'passport'
config = require './config/config'

app = express()

require('./config/mongodb') config
require('./config/passport') config, passport
require('./config/express') app, config, passport
require('./config/mailer') config
require('./config/events') config
require('./config/routes') app, config

module.exports = app
