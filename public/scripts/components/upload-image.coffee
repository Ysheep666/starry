# 上传图片
$ = require 'jquery'
Flow = require 'flow'

{upyun} = adou

class Upload
  constructor: ->
    # Options 可以给之后的扩展使用
    options =
      target: upyun.api + '/starry-images'
      singleFile: true
      testChunks: false

    @flow = new Flow options

  assignBrowse: ->
    @flow.assignBrowse arguments

  assignDrop: ->
    @flow.assignDrop arguments

  upload: ->
    @flow.upload()

  on: (event, callback) ->
    if event is 'filesSubmitted'
      @flow.on event, (files) =>
        return callback '图片大小不能超过 2M' if 2 * 1024 * 1024 < files[0].size
        return callback '图片格式错误' if not /^.*(\.jpg|\.jpeg|\.bmp|\.gif|\.png)$/.test files[0].name.toLowerCase()
        $.ajax
          url: '/api/upyun_token'
          type: 'POST'
          data:
            bucket: 'starry-images'
            expiration: parseInt (new Date().getTime() + 600000)/1000, 10
            'save-key': '/{year}{mon}/{day}/{filemd5}-{random}{.suffix}'
          dataType: 'json'
        .done (data) =>
          data['content-length-range'] = '0,2048000'
          @flow.opts.query = data
          callback()
        .fail (res) ->
          error = res.responseJSON.error
          if typeof error is 'string' then errors = [error] else errors = (err.msg for err in error)
          callback errors.join('<br>')
    else
      @flow.on event, callback

module.exports = Upload
