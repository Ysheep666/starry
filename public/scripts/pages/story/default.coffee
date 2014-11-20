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

    # 新建故事
    $('#addStory').on 'click', (event) ->
      event.preventDefault()
      $.ajax
        url: '/api/stories'
        type: 'POST'
        dataType: 'json'
      .done (data) ->
        router.setRoute "stories/#{data._id}"
      .fail (res) ->
        error = res.responseJSON.error
        window.alert error

    $wrap.removeClass 'bige'

  _detail = (data) ->
    $detail.html templates.detail data

    {story} = data

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
      image = upyun.buckets['starry-images'] + message.url
      $.ajax
        url: "/api/stories/#{story._id}"
        type: 'POST'
        data: background: image
        dataType: 'json'
      .done (res) ->
        window.setTimeout ->
          $replaceBackground.removeClass 'loading'
          $replaceBackground.closest('.section-background').css 'backgroundImage', "url(#{image})"
        , 800
      .fail (res) ->
        error = res.responseJSON.error
        window.alert error

    # 上传头像
    $profileImage = $('#profileImage')
    profileImageUpload = new Upload()
    profileImageUpload.assignBrowse $profileImage[0]
    profileImageUpload.assignDrop $profileImage[0]
    profileImageUpload.on 'filesAdded', ->
      $profileImage.closest('.profile-image').addClass 'loading'
    profileImageUpload.on 'filesSubmitted', (err) ->
      return window.alert err if err
      profileImageUpload.upload()
    profileImageUpload.on 'fileSuccess', (file, message) ->
      message = JSON.parse message
      image = upyun.buckets['starry-images'] + message.url
      $.ajax
        url: "/api/stories/#{story._id}"
        type: 'POST'
        data: cover: image
        dataType: 'json'
      .done (res) ->
        window.setTimeout ->
          $profileImage.removeClass('loading').addClass 'done'
          $profileImage.css 'backgroundImage', "url(#{image}!avatar)"
        , 800
      .fail (res) ->
        error = res.responseJSON.error
        window.alert error

    # 主题
    $('body').attr 'class', story.theme if story.theme

    $('#themes').on 'click', 'a', (event) ->
      event.preventDefault()
      theme = $(this).data 'color'
      $.ajax
        url: "/api/stories/#{story._id}"
        type: 'POST'
        data: theme: theme
        dataType: 'json'
      .done (res) ->
        $('body').attr 'class', theme
      .fail (res) ->
        error = res.responseJSON.error
        window.alert error



    $wrap.addClass 'bige'

  router = new Router()

  # 列表
  router.on '/stories', ->
    if preloaded
      _list { logo: _logo(), stories: preloaded.stories }
      return preloaded = null

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
  router.on '/stories/:id', (id) ->
    if preloaded
      _detail { story: preloaded.story }
      return preloaded = null

    $.ajax
      url: "/api/stories/#{id}"
      type: 'GET'
      dataType: 'json'
    .done (res) ->
      _detail { story: res }
    .fail (res) ->
      error = res.responseJSON.error
      window.alert error

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
