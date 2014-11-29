# 图表
$ = require 'jquery'

class Chart
  @DEFAULTS:
    container: $('body')

  constructor: (options) ->
    @options = $.extend {}, Chart.DEFAULTS, options
    @container = @options.container
    @container.on 'focusin', '[rel-chart="yes"]', (event) =>
      @$el = $ event.currentTarget
      @$el.on 'input', => @_analyse @$el.val()
      @$el.one 'focusout', => @$el.unbind 'input'

  # 分析
  _analyse: (val) ->
    percent = if /^([0-9]{1,3}\%)$/.test(val) then parseInt val.replace('%', ''), 10 else null
    if percent && percent >= 0 && percent <= 100
      $chart = @$el.siblings '.chart'
      if not $chart.data('easyPieChart')
        $chart.addClass('open').easyPieChart
          scaleColor: false
          size: 18
          lineWidth: 9
          barColor: $chart.css 'color'
          lineCap: 'butt'
          trackColor: 'transparent'

      $chart.data('easyPieChart').update percent
    else
      @$el.siblings('.chart').data('easyPieChart', null).html('').removeClass 'open'

module.exports = Chart
