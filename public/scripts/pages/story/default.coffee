$ = require 'jquery'
Router = require 'router'
Flow = require 'flow'
require '../../components/csrf'

_logo = require '../../templates/components/logo.hbs'

templates =
  list: require '../../templates/pages/story/list.hbs'
  detail: require '../../templates/pages/story/detail.hbs'

{upyun, preloaded} = adou

$ ->
  $wrap = $ '#wrap'
  $list = $ '#list'
  $detail = $ '#detail'

  router = new Router()

  # 列表
  router.on '/stories', ->
    if preloaded.stories
      $list.html templates.list { logo: _logo(), stories: preloaded.stories }

      $wrap.removeClass 'bige'
      return preloaded.stories = null

    alert 'x'


  # 详情
  router.on '/stories/:id', ->
    $detail.html templates.detail()
    $wrap.addClass 'bige'

  router.configure html5history: true
  router.init()

  $('body').on 'click', 'a.go', (event) ->
    event.preventDefault()
    router.setRoute $(event.currentTarget).attr 'href'

#   flow = new Flow
#     target: upyun.api + '/starry-images'
#     singleFile: true
#     testChunks: false
#
#   flow.assignBrowse $('#replaceImage')[0]
#   flow.on 'filesSubmitted', ->
#     $.ajax
#       url: '/api/upyun_token'
#       type: 'POST'
#       data:
#         bucket: 'starry-images'
#         expiration: parseInt (new Date().getTime() + 600000)/1000, 10
#         'save-key': '/{year}{mon}/{day}/{filemd5}-{random}{.suffix}'
#       dataType: 'json'
#     .done (res) ->
#       flow.opts.query = res
#       flow.upload()
#     .fail (res) ->
#       error = res.responseJSON.error
#       window.alert error
#
#   flow.on 'fileSuccess', (file, message) ->
#     message = JSON.parse message
#     $('body').append "<img src='#{upyun.buckets['starry-images']}#{message.url}'>"
