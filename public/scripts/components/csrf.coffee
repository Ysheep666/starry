# csrf
$ = require 'jquery'
$.ajaxSetup
  beforeSend: (xhr, settings) ->
    xhr.setRequestHeader 'x-csrf-token', $.cookie('_csrf') if settings.type is 'POST' or settings.type is 'PUT' or settings.type == 'DELETE'
