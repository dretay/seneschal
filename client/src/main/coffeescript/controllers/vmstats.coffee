define [
    'c/controllers'
    'chroma'
    'reconnectingWebsocket'
    'smoothie'
    'sugar'
  ],
(controllers, chroma, ReconnectingWebSocket, smoothie, sugar) ->
  'use strict'

  controllers.controller 'vmstats', ['$scope', '$timeout', '$routeParams',  ($scope, $timeout, $routeParams) ->

    allTimeSeries = []
    allValueLabels = []
    descriptions =
      'Processes':
        'r': 'Number of processes waiting for run time'
        'b': 'Number of processes in uninterruptible sleep'

      'Memory':
        'swpd': 'Amount of virtual memory used'
        'free': 'Amount of idle memory'
        'buff': 'Amount of memory used as buffers'
        'cache': 'Amount of memory used as cache'

      'Swap':
        'si': 'Amount of memory swapped in from disk'
        'so': 'Amount of memory swapped to disk'

      'IO':
        'bi': 'Blocks received from a block device (blocks/s)'
        'bo': 'Blocks sent to a block device (blocks/s)'

      'System':
        'in': 'Number of interrupts per second, including the clock',
        'cs': 'Number of context switches per second'

      'CPU':
        'us': 'Time spent running non-kernel code (user time, including nice time)'
        'sy': 'Time spent running kernel code (system time)'
        'id': 'Time spent idle'
        'wa': 'Time spent waiting for IO'

    streamStats = ->
      ws = new ReconnectingWebSocket("wss://#{location.host}/vmstats?token=#{encodeURIComponent($routeParams.token)}")
      lineCount =0
      colHeadings = []
      ws.onopen = ->
        console.log('connect')
        lineCount = 0

      ws.onclose = ->
        console.log('disconnect')

      ws.onmessage = (e)->
        switch lineCount++
          #ignore first line
          when 0 then null

          #column headings
          when 1
            colHeadings = e.data.trim().split /\s+/

          #subsequent lines
          else
            stats = {}
            colValues = e.data.trim().split /\s+/
            stats[colHeadings[i]] = parseInt(colValues[i]) for i in [0..colHeadings.length]
            receiveStats stats


    initCharts = ->
        Object.each descriptions, (sectionName, values)->
          section = $('.chart.template').clone().removeClass('template').appendTo('#charts')

          section.find('.title').text(sectionName)

          smoothie = new SmoothieChart
            grid:
              sharpLines: true
              verticalSections: 5
              strokeStyle: 'rgba(119,119,119,0.45)'
              millisPerLine: 1000
            minValue: 0
            labels:
              disabled: true


          smoothie.streamTo section.find('canvas').get(0), 1000

          colors = chroma.brewer['Pastel2']
          index = 0
          Object.each values, (name, valueDescription)->
            color = colors[index++]

            timeSeries = new TimeSeries()
            smoothie.addTimeSeries timeSeries,
              strokeStyle: color
              fillStyle: chroma(color).darken().alpha(0.5).css()
              lineWidth: 3

            allTimeSeries[name] = timeSeries

            statLine = section.find('.stat.template').clone().removeClass('template').appendTo(section.find('.stats'))
            statLine.attr('title', valueDescription).css('color', color)
            statLine.find('.stat-name').text(name)
            allValueLabels[name] = statLine.find('.stat-value')

    receiveStats = (stats)->
      Object.each stats, (name, value)->
        timeSeries = allTimeSeries[name];
        if timeSeries
          timeSeries.append(Date.now(), value)
          allValueLabels[name].text(value)

    initCharts()
    streamStats()
  ]