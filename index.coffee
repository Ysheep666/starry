# Application
path = require 'path'
express = require 'express'
passport = require 'passport'

config = require './libs/config'

{setting, db, mailer} = config

app = express()

require('./libs/mongoose') db
require('./libs/passport') passport
require('./libs/express') app, passport, setting, db
require('./libs/mailer') setting, db
require('./libs/router') app, setting

module.exports = app
