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
      eventName.replace(/\/|\./g, '_')+"#{@$id}"

    restrict: 'EA'
    scope:
      eventName: '@listenTo'
      height: '@height'
      width: '@width'
      key: '@'
      series: '='
      criteria: '='
    replace: false,
    template: """
      <canvas id="{{toDomName(eventName)}}_chart" height="{{height}}" width="{{width}}"></canvas>
      <div ng-style="getFooterStyle()">
        <ul class="stats">
          <li ng:repeat="label in _labels" style="list-style-type: none;float: left;width: 130px">
            <span ng-style="label.style">{{label.name}}</span><span ng-style="label.style" style="padding-left: 10px;font-weight:bold">{{label.value}}</span>
          </li>
        </ul>
      </div>
    """

    link:
      pre: (scope, iElement, iAttrs)->

      post: (scope, iElement, iAttrs)->
        scope.getFooterStyle= ->
          "width": "#{iAttrs.width}px"
          "height": "2em"
          "background": "black"
          "top": "-16px"
          "position": "relative"
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
          scope.smoothie.streamTo($('#' + toDomName.call(scope,scope.eventName) + '_chart')[0], 1000)
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
            data = _.findWhere data, scope.criteria if scope.criteria?
            data = data[scope.key] if scope.key? and not _.isEmpty data[scope.key]
            if _.isObject(data) and not _.isArray(data)
              collector = []
              for name, desc of scope.series
                collector.push Math.abs(data[name]) if _.isNumber data[name]
              data = collector
            if _.isUndefined(scope.criteria) or not _.isNull(scope.criteria)
              for element, i in data
                scope._series[i].append(new Date().getTime(), data[i])
                scope._labels[i].value = data[i]
                scope.$apply()

          scope.$on '$destroy', ->
            client.unsubscribe subscription.id
