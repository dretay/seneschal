define [
  'c/controllers'
  'underscore'
  'jquery'
  'c/lights'
  's/lights'
  's/alarmZones'
  's/alarmKeypads'
  's/cameras'
  's/nest'
  's/garageDoors'
  'p/webStomp'
  'd/light'
  'd/alarmZone'
  'd/alarmKeypad'
  'd/camera'
  'd/thermostat'
  'd/garageDoor'
  'f/itemsOnFloor'
  'f/oddLengthString'
],
(controllers, _, $) ->
  'use strict'

  controllers.controller 'lights', ['$scope', '$timeout', '$routeParams', 'lights', 'alarmZones', 'alarmKeypads', 'cameras', 'nest', 'garageDoors', 'webStomp', '$modal', '$log', ($scope, $timeout, $routeParams, lights, alarmZones, alarmKeypads, cameras, nest, garageDoors, webStomp, $modal, $log) ->

    #TODO: this has to be in controller scope, but should probably be handled as a mixin!
    $scope.$on '$destroy', -> webStomp.client.unsubscribe id for id, handler of webStomp.subscriptions

    lights.token = $routeParams.token
    $scope.lights = lights.query()
    $scope.alarmZones = alarmZones.query()
    $scope.alarmKeypads = alarmKeypads.query()
    $scope.cameras = cameras.query()
    $scope.nest = nest.query({}, false)
    $scope.garageDoors = garageDoors.query()
    $scope.loading = true
    $scope._ = _
    $scope.$watch 'lights', (newVal, oldVal)->
      $scope.loading = if newVal.length > 0 then false else true
    , true
    # $scope.$watch 'alarmKeypads', (newVal, oldVal)->
    #   if _.isObject(newVal[0]) then $scope.apply()
    # , true

    $scope.isArmed = ->
        if _.isObject($scope.alarmKeypads[0])
          leds = $scope.alarmKeypads[0].data.leds
          if (leds['ARMED STAY'] || leds['ARMED (ZERO ENTRY DELAY)'] || leds['ARMED AWAY']) then return "armed" else return "unarmed"
        "unavailable"
    $scope.alarmStatusIcon= ->
      if $scope.isArmed() == "unavailable"
        'fa fa-spin fa-spinner fa-2x'
      else if $scope.isArmed() == "armed"
        'fa fa-lock fa-2x'
      else
        'fa fa-unlock fa-2x'


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

    $scope.activeFloor = $scope.floors.mainFloor
    $scope.openKeypad= (size)->
        modalInstance = $modal.open
          templateUrl: '/html/modals/keypadModal.html'
          controller: ($scope, $modalInstance, alarmKeypads, webStomp, defaultKeypad)->
            this.alarmKeypads = alarmKeypads

            #TODO: this should be part of some over-arching mechanic...
            $scope.$on '$destroy', -> webStomp.client.unsubscribe alarmKeypads.subscriptionHandler.id

            $scope.defaultKeypad = defaultKeypad
            $scope.keypads = alarmKeypads.query()
            $scope.modalOpen = true
            $scope.form=
              commands:
                away: false
                stay: false
                instant: true
              passcode: ""

            $scope.getKeypad = ->
              if $scope.keypads.length > 0
                $scope.keypads[0]
              else
                $scope.defaultKeypad
            $scope.ok = ->
              if $scope.getKeypad().data.leds.READY
                command = _.find (for command, value of $scope.form.commands then if value then command), (cmd)-> !_.isUndefined cmd
                if command == "instant"
                  $modalInstance.close "#3"
                else if command == "stay"
                  $modalInstance.close "#{$scope.form.passcode}3"
                else
                  $modalInstance.close "#{$scope.form.passcode}2"
              else
                $modalInstance.close "#{$scope.form.passcode}1"

            $scope.cancel = ->
              $scope.modalOpen = false
              $modalInstance.dismiss('cancel')
          size: size
          resolve:
            defaultKeypad: -> $scope.alarmKeypads[0]


        modalInstance.result.then (command)->
            webStomp.client.send "/amq/queue/eyezon.alarm",null, command
        ,->
          $log.info('Modal dismissed at: ' + new Date());
  ]
