define [
    'c/controllers'
    'underscore'
    'jquery'
    'modals/AlarmModal'
    's/switches'
    's/alarmZones'
    's/cameras'
    's/nest'
    's/garageDoors'
    's/tempAndHum'
    'p/webStomp'
    'd/switch'
    'd/alarmZone'
    'd/alarmKeypad'
    'd/camera'
    'd/thermostat'
    'd/alarmKeypadStatus'
    'd/alarmZoneStatus'
    'd/sensor'
    'f/itemsOnFloor'
    'f/oddLengthString'
    's/controlsOffCanvas'
  ],
(controllers, _, $) ->
  'use strict'

  controllers.controller 'controls', ['$scope', '$timeout', '$routeParams', 'switches', 'alarmZones',
                                      'cameras', 'nest', 'garageDoors', 'tempAndHum', 'webStomp', '$modal', '$log', 'controlsOffCanvas'
    ($scope, $timeout, $routeParams, switches, alarmZones, cameras, nest, garageDoors, tempAndHum, webStomp, $modal, $log, controlsOffCanvas) ->

      $log.debug "Controls::controller populating scope"
      $scope.activeFloor = $routeParams.floor
      $scope.switches = switches.query(null,{scope:$scope})
      $scope.alarmZones = alarmZones.query(null,{scope:$scope})
      $scope.cameras = cameras.query()
      $scope.nest = nest.query(null,{isArray:false, scope:$scope})
      $scope.garageDoors = garageDoors.query(null,{scope:$scope})
      $scope.tempAndHum = tempAndHum.query(null,{scope:$scope})
      $scope.loading = true
      $scope._ = _
      $scope.toggle = controlsOffCanvas.toggle

      $scope.isActiveFloor = (floor)->
        if floor == $scope.activeFloor then "active" else ""

      $scope.floors =
        basement:
          name: "basement"
          url: '/stylesheets/img/basement.png'

        mainFloor:
          name: "mainFloor"
          url: '/stylesheets/img/mainfloor.png'

        secondFloor:
          name: "secondFloor"
          url: '/stylesheets/img/2ndfloor.png'

      $scope.activeFloor = $scope.floors[$routeParams.floor]

  ]
