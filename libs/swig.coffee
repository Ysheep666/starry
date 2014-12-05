# swig 模板
module.exports = (swig) ->
  swig.setFilter 'circle', (bubble) ->
    return '<div class="circle"></div>' if not bubble
    progress = if /^([0-9]{1,3}\%)$/.test(bubble) then parseInt bubble.replace('%', ''), 10 else null
    return "<div class='circle circle-general'><div class='chart' data-progress='#{progress}'></div></div>" if progress && progress >= 0 && progress <= 100
    return "<div class='circle circle-general'><i class='fa fa-#{bubble.substr(5)}'></i></div>" if 0 is bubble.indexOf 'icon-'
    return "<div class='circle circle-large'><div class='visible'>#{bubble}</div></div>"

  swig.setFilter 'circle_type', (bubble) ->
    return '' if not bubble
    progress = if /^([0-9]{1,3}\%)$/.test(bubble) then parseInt bubble.replace('%', ''), 10 else null
    return 'progress' if progress && progress >= 0 && progress <= 100
    return 'icon' if 0 is bubble.indexOf 'icon-'
    return 'text'
