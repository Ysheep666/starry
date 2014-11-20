$ = require 'jquery'
toastr = require 'toastr'
require '../../components/csrf'

$ ->
  $form = $ '#formSignin'
  $inputs = $form.find '.inputs'
  $submit = $form.find 'button[type="submit"]'

  $form.on 'submit', (event) ->
    event.preventDefault()
    $submit.button 'loading'
    $.ajax
      url: '/api/signin'
      type: 'POST'
      data: $form.serialize()
      dataType: 'json'
    .done (res) ->
      $submit.button 'reset'
      window.location.href = '/'
    .fail (res) ->
      $submit.button 'reset'
      error = res.responseJSON.error
      if typeof error is 'string' then errors = [error] else errors = (err.msg for err in error)
      toastr.error errors.join('<br>'), '登陆失败!'
