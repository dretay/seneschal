define [
  'c/controllers'
  'underscore'
  'jquery'
  's/switches'
  's/alarmZones'
  's/alarmKeypads'
  's/cameras'
  's/nest'
  's/garageDoors'
  'p/webStomp'
  'd/light'
  'd/fan'
  'd/alarmZone'
  'd/alarmKeypad'
  'd/camera'
  'd/thermostat'
  'd/garageDoor'
  'f/itemsOnFloor'
  'f/oddLengthString'
  'f/switchType'
],
(controllers, _, $) ->
  'use strict'

  controllers.controller 'controls', ['$scope', '$timeout', '$routeParams', 'switches', 'alarmZones', 'alarmKeypads', 'cameras', 'nest', 'garageDoors', 'webStomp', '$modal', '$log', ($scope, $timeout, $routeParams, switches, alarmZones, alarmKeypads, cameras, nest, garageDoors, webStomp, $modal, $log) ->

    #TODO: this has to be in controller scope, but should probably be handled as a mixin!
    $scope.$on '$destroy', -> webStomp.client.unsubscribe id for id, handler of webStomp.subscriptions

    switches.token = $routeParams.token

    $scope.activeFloor = $routeParams.floor
    $scope.switches = switches.query()
    $scope.alarmZones = alarmZones.query()
    $scope.alarmKeypads = alarmKeypads.query()
    $scope.cameras = cameras.query()
    $scope.nest = nest.query({}, false)
    $scope.garageDoors = garageDoors.query()
    $scope.loading = true
    $scope._ = _


    $scope.isArmed = ->
        if _.isObject($scope.alarmKeypads[0])
          leds = $scope.alarmKeypads[0].data.leds
          if (leds['ARMED STAY'] || leds['ARMED (ZERO ENTRY DELAY)'] || leds['ARMED AWAY']) then return "armed" else return "unarmed"
        "unavailable"

    $scope.alarmColor = ->
      if $scope.isArmed() == "unavailable"
        "grey"
      else if $scope.isArmed() == "armed"
        "red"
      else
        "green"
    $scope.alarmStatusClass = -> "alarmStatus-#{$scope.alarmColor()}"

    $scope.alarmBorderClass = -> "alarmBorder-#{$scope.alarmColor()}"

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
