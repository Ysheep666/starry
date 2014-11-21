# config 配置
path = require 'path'
fs = require 'fs'
_ = require 'lodash'
yaml = require 'js-yaml'

env = process.env.NODE_ENV or 'development'
root = path.normalize path.join  __dirname, '../'
configPath = path.join root, 'config'

_read = (file) ->
  return {} if not fs.existsSync file
  return yaml.safeLoad fs.readFileSync file, 'utf8'

defaultOptions = _read "#{configPath}/default.yaml"

options =  _.merge defaultOptions, _read "#{configPath}/#{env}.yaml"
options.setting.root = root

global.adou = {}

module.exports = adou.config = options
