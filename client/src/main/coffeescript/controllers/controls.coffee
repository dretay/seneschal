define [
    'c/controllers'
    'underscore'
    'jquery'
    'modals/AlarmModal'
    's/switches'
    's/alarmZones'
    's/alarmKeypad'
    's/cameras'
    's/nest'
    's/garageDoors'
    'p/webStomp'
    'd/switch'
    'd/alarmZone'
    'd/alarmKeypad'
    'd/camera'
    'd/thermostat'
    'f/itemsOnFloor'
    'f/oddLengthString'

  ],
(controllers, _, $, AlarmModal) ->
  'use strict'

  controllers.controller 'controls', ['$scope', '$timeout', '$routeParams', 'switches', 'alarmZones', 'alarmKeypad',
                                      'cameras', 'nest', 'garageDoors', 'webStomp', '$modal', '$log',
    ($scope, $timeout, $routeParams, switches, alarmZones, alarmKeypad, cameras, nest, garageDoors, webStomp, $modal, $log) ->

      #TODO: this has to be in controller scope, but should probably be handled as a mixin!
#      $scope.$on '$destroy', -> webStomp.client.unsubscribe id for id, handler of webStomp.subscriptions


      $scope.activeFloor = $routeParams.floor
      $scope.switches = switches.query(null,{scope:$scope})
      $scope.alarmZones = alarmZones.query(null,{scope:$scope})
      $scope.alarmKeypad = alarmKeypad.query(null,{isArray:false, scope:$scope})
      $scope.cameras = cameras.query()
      $scope.nest = nest.query(null,{isArray:false, scope:$scope})
      $scope.garageDoors = garageDoors.query(null,{scope:$scope})
      $scope.loading = true
      $scope._ = _


      $scope.openAlarmModal = ()->
        modalInstance = $modal.open AlarmModal $scope.alarmKeypad, "sm"

        modalInstance.result.then (command)->
          webStomp.client.send "/exchange/alarm.cmd", null, command
        , ->
          $log.info('Modal dismissed at: ' + new Date());

      $scope.isArmed = ->
        if not _.isEmpty $scope.alarmKeypad
          leds = $scope.alarmKeypad.data.leds
          if (leds['ARMED STAY'] || leds['ARMED (ZERO ENTRY DELAY)'] || leds['ARMED AWAY']) then return "Armed" else return "Disarmed"
        "unavailable"


      $scope.alarmColorClass = ->
        if $scope.isArmed() == "unavailable"
          "text-default"
        else if $scope.isArmed() == "Armed"
          "text-danger"
        else
          "text-success"

      $scope.alarmStatusMsg = ->
        if not _.isEmpty $scope.alarmKeypad then $scope.alarmKeypad.data.message.substr(0,15)

      $scope.isActiveFloor = (floor)->
        if floor == $scope.activeFloor then "active" else ""

      $scope.floors =
        basement:
          name: "basement"
          url: '/stylesheets/img/basement_optimized.png'

        mainFloor:
          name: "mainFloor"
          url: '/stylesheets/img/mainfloor_optimized.png'

        secondFloor:
          name: "secondFloor"
          url: '/stylesheets/img/2ndfloor_optimized.png'

      $scope.activeFloor = $scope.floors[$routeParams.floor]

  ]
