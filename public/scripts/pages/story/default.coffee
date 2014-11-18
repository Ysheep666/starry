$ = require 'jquery'
Router = require 'router'
require '../../components/csrf'

Upload = require '../../components/upload-image'

_logo = require '../../templates/components/logo.hbs'

templates =
  list: require '../../templates/pages/story/list.hbs'
  detail: require '../../templates/pages/story/detail.hbs'

{upyun, preloaded} = adou

$ ->
  $wrap = $ '#wrap'
  $list = $ '#list'
  $detail = $ '#detail'

  _list = (data) ->
    $list.html templates.list data
    $wrap.removeClass 'bige'

  _detail = (data) ->
    $detail.html templates.detail data

    # 替换背景图
    $replaceBackground = $('#replaceBackground')
    replaceBackgroundUpload = new Upload()
    replaceBackgroundUpload.assignBrowse $replaceBackground[0]
    replaceBackgroundUpload.on 'filesAdded', ->
      $replaceBackground.addClass 'loading'
    replaceBackgroundUpload.on 'filesSubmitted', (err) ->
      return window.alert err if err
      replaceBackgroundUpload.upload()
    replaceBackgroundUpload.on 'fileSuccess', (file, message) ->
      message = JSON.parse message
      setTimeout ->
        $replaceBackground.removeClass 'loading'
        $replaceBackground.closest('.section-background').css 'backgroundImage', "url(#{upyun.buckets['starry-images']}#{message.url})"
      , 1000

    # 上传头像
    $profileImage = $('#profileImage')
    profileImageUpload = new Upload()
    profileImageUpload.assignBrowse $profileImage[0]
    profileImageUpload.on 'filesAdded', ->
      $profileImage.closest('.profile-image').addClass 'loading'
    profileImageUpload.on 'filesSubmitted', (err) ->
      return window.alert err if err
      profileImageUpload.upload()
    profileImageUpload.on 'fileSuccess', (file, message) ->
      message = JSON.parse message
      setTimeout ->
        $profileImage.removeClass('loading').addClass 'done'
        $profileImage.css 'backgroundImage', "url(#{upyun.buckets['starry-images']}#{message.url}!avatar)"
      , 1000

    $wrap.addClass 'bige'

  router = new Router()

  # 列表
  router.on '/stories', ->
    if preloaded.stories
      _list { logo: _logo(), stories: preloaded.stories }
      return preloaded.stories = null

    $.ajax
      url: '/api/stories'
      type: 'GET'
      dataType: 'json'
    .done (res) ->
      _list { logo: _logo(), stories: res }
    .fail (res) ->
      error = res.responseJSON.error
      window.alert error

  # 详情
  router.on '/stories/:id', ->
    _detail {}

  router.configure html5history: true
  router.init()

  # 跳转
  $('body').on 'click', 'a.go', (event) ->
    event.preventDefault()
    router.setRoute $(event.currentTarget).attr 'href'

  # 退出登录
  $('body').on 'click', 'a.signout', (event) ->
    event.preventDefault()
    $.ajax
      url: '/api/signin'
      type: 'DELETE'
      dataType: 'json'
    .always ->
      window.location.href = '/'

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
