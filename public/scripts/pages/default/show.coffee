$ = require 'jquery'

$ ->
  $window = $ window
  width = $window.width()
  if width < 800
    adou.backgroundSuffix = 'background800'
  else if width > 600 and width < 1200
    adou.backgroundSuffix = 'background1024'
  else
    adou.backgroundSuffix = 'background1600'

  $background = $ '.section-background'
  $background.css 'backgroundImage', "url(#{$background.data('background')}!#{adou.backgroundSuffix})" if $background.data 'background'

  $('.section').each (index) ->
    $el = $ this
    if 0 is index%2 then $el.addClass 'section-black' else $el.removeClass 'section-black'

  $('.point').each (index) ->
    $el = $ this
    if 0 is index%2 then $el.removeClass 'point-right' else $el.addClass 'point-right'

  $('.circle .chart').each ->
    $el = $ this
    $el.easyPieChart
      scaleColor: false
      size: 31
      lineWidth: 15.5
      barColor: $el.css 'color'
      lineCap: 'butt'
      trackColor: 'transparent'

    $el.on 'mouseenter', ->
      pie = $el.data 'easyPieChart'
      pie.update 0
      pie.update $el.data 'progress'

    $el.data('easyPieChart').update $el.data 'progress'

  $('body').on 'click', 'a[href*=#]', (event) ->
    event.preventDefault()
    $target = $ '#' + @hash.slice 1
    $('html, body').animate { scrollTop: $target.position().top }, 600 if $target.length

  $window.on 'scroll', ->
    $('.point').each (index) ->
      $el = $ this
      if (0 < $window.scrollTop() + $window.height() - $el.offset().top) && !$el.hasClass 'swing-in'
        $chart = $el.find '.circle .chart'
        window.setTimeout ->
          if $chart.length
            pie = $chart.data 'easyPieChart'
            pie.update 0
            pie.update $chart.data 'progress'
          $el.addClass 'swing-in'
        , 200

