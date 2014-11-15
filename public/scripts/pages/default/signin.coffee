$ = require 'jquery'
template = require '../../templates/components/alert.hbs'
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
      $alert = $(template errors: errors).addClass 'alert-danger'
      $_alert = $inputs.prev '.alert'
      if $_alert.size() then $_alert.replaceWith $alert else $inputs.before $alert
