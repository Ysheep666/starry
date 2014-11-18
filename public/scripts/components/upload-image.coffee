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
      @flow.on event, =>
        $.ajax
          url: '/api/upyun_token'
          type: 'POST'
          data:
            bucket: 'starry-images'
            expiration: parseInt (new Date().getTime() + 600000)/1000, 10
            'save-key': '/{year}{mon}/{day}/{filemd5}-{random}{.suffix}'
          dataType: 'json'
        .done (res) =>
          @flow.opts.query = res
          callback()
        .fail (res) ->
          callback res.responseJSON.error
    else
      @flow.on event, callback

module.exports = Upload
# flow = new Flow
#   target: upyun.api + '/starry-images'
#   singleFile: true
#   testChunks: false
#
# flow.assignBrowse $('#replaceImage')[0]
# flow.on 'filesSubmitted', ->
#   $.ajax
#     url: '/api/upyun_token'
#     type: 'POST'
#     data:
#       bucket: 'starry-images'
#       expiration: parseInt (new Date().getTime() + 600000)/1000, 10
#       'save-key': '/{year}{mon}/{day}/{filemd5}-{random}{.suffix}'
#     dataType: 'json'
#   .done (res) ->
#     flow.opts.query = res
#     flow.upload()
#   .fail (res) ->
#     error = res.responseJSON.error
#     window.alert error

# flow.on 'fileSuccess', (file, message) ->
#   message = JSON.parse message
#   $('body').append "<img src='#{upyun.buckets['starry-images']}#{message.url}'>"
