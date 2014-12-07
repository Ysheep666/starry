$ = require 'jquery'
toastr = require 'toastr'
ZeroClipboard = require 'zero-clipboard'

toastr.options.positionClass = 'toast-bottom-right'
ZeroClipboard.config swfPath: '../../ZeroClipboard.swf'

$ ->
  $qrcode = $ '#qrcode'
  $qrcode.qrcode
    width: 160
    height: 160
    text: 'http://' + $qrcode.data 'url'

  $copy = $ '#copy'
  client = new ZeroClipboard $copy[0]
  client.on 'aftercopy', ->
    toastr.success '拷贝成功!'