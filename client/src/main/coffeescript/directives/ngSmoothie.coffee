define [
    'd/directives'
    'm/applianceMixin'
    'jquery'
    'underscore'
    'chroma'
    'smoothie'
    'p/webStomp'
  ],
(directives, applianceMixin, $, _, chroma) ->
  'use strict'

  directives.directive 'ngSmoothie', (webStomp, $timeout)->
    toDomName = (eventName)->
      eventName.replace(/\/|\./g, "_")

    restrict: 'EA'
    scope:
      eventName: '@listenTo'
      height: '@height'
      width: '@width'
      series: '='
    replace: false,
    template: """
      <canvas id="{{toDomName(eventName)}}_chart" height="{{height}}" width="{{width}}"></canvas>
      <ul class="stats">
        <li ng:repeat="label in _labels" style="list-style-type: none;float: left;width: 130px">
          <span ng-style="label.style">{{label.name}}</span><span ng-style="label.style" style="padding-left: 10px;font-weight:bold">{{label.value}}</span>
        </li>
      </ul>
    """

    link:
      pre: (scope, iElement, iAttrs)->

      post: (scope, iElement, iAttrs)->
        index = 0
        scope.toDomName = toDomName
        scope.smoothie = new SmoothieChart
          sharpLines: true
          verticalSections: 5
          minValue: 0
          millisPerPixel: iAttrs.speed || 20,
          interpolation: iAttrs.interpolation || 'bezier'
          labels:
            disabled: true

        scope._series = []
        scope._labels = []
        $timeout ->
          scope.smoothie.streamTo($('#' + toDomName(scope.eventName) + '_chart')[0], 1000)
          colors = chroma.brewer['Pastel2']
          for name, valueDescription of scope.series
            color = colors[index++]

            timeSeries = new TimeSeries()
            scope.smoothie.addTimeSeries timeSeries,
              strokeStyle: color
              fillStyle: chroma(color).darken().alpha(0.5).css()
              lineWidth: 3

            scope._series.push timeSeries
            scope._labels.push
              name: name
              value: ""
              style:
                "color": color

        , 100

        webStomp.getClient().then (client)=>
          subscription = client.subscribe iAttrs.listenTo, (data)->
            data = JSON.parse(data.body)
            for element, i in data
              scope._series[i].append(new Date().getTime(), data[i])
              scope._labels[i].value = data[i]
              scope.$apply()

          scope.$on '$destroy', ->
            client.unsubscribe subscription.id
