define [
    'c/controllers'
    's/services'
    'd/sensor'
    's/mySensors'
    's/mySensorsNode'
  ],
(controllers, services) ->
  'use strict'

  services.factory 'allMySensors', ['webStompResource', (Resource)->
    new Resource
      get:
        outbound_rpc: "/exchange/mysensors.cmd"
        outboundTransform: (rawData)->
          cmd: "getAllSensors"
        inboundTransform: (sensors, oldData)->
          _.filter sensors, (sensor)-> sensor.sensorindex < 254

  ]
  controllers.controller 'stats', ['$scope', '$interval', 'allMySensors', 'ngTableParams', 'mySensorsNode', ($scope, $interval, allMySensors, ngTableParams, mySensorsNode) ->

    $scope.sensors = allMySensors.query(null,{scope:$scope})

    $scope.getSensorLabels = (sensor)->
      (_.pluck sensor.data, "label").join(",")

    $scope.dataEmpty = ->
      _.isEmpty $scope.data

    $scope.data = []

    $scope.binSize = 'hour'

    $scope.checkboxes =
      'checked': false
      items: {}

    $scope.xAxisTickFormat = ->
      (d)->
        if $scope.binSize == "hour" or $scope.binSize == "minute"
          d3.time.format('%X')(new Date(d))
        else
          d3.time.format('%x')(new Date(d))



    $scope.startDate = moment().subtract(1,'days').toDate()
    $scope.endDate = moment().add(1,'days').toDate()
    $scope.maxDate = moment().add(1,'days').toDate()

    $scope.dateOptions =
      formatYear: 'yy'
      startingDay: 1
    $scope.formats = ['dd-MMMM-yyyy', 'yyyy/MM/dd', 'dd.MM.yyyy', 'shortDate'];
    $scope.format = $scope.formats[0];

    $scope.open = ($event,target)->
      $event.preventDefault()
      $event.stopPropagation()

      $scope[target] = true

    redrawChart = ->
      if _.isArray $scope.sensors
        nodes = []
        _.each $scope.checkboxes.items, (value, key, list)->
          if value then nodes.push "#{key}"
        if nodes.length > 0
          $scope.data = mySensorsNode.query({binUnit: $scope.binSize, nodes: nodes, startDate: $scope.startDate, endDate: $scope.endDate},{scope:$scope})

    $scope.$watch ->
      binSize: $scope.binSize
      checkboxItems: $scope.checkboxes.items
      startDate: $scope.startDate
      endDate: $scope.endDate
    , ()->
        redrawChart()
    , true


    $scope.tableParams = new ngTableParams {
        page: 1
        total: 1
      },
      {
        counts: []
      }

  ]