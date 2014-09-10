define [
    'd/directives'
    'jquery'
    'underscore'
    'modals/AlarmModal'
    's/alarmKeypad'
  ],
(directives, $, _, AlarmModal) ->
  'use strict'

  directives.directive 'alarmKeypad', ->
    restrict: 'E'
    replace: false
    template: "<span class='fa fa-lock fa-stack-1x' ng-class='getClass()' ng-click='click()'></span>"

    controller: ($scope, $injector, $timeout, $modal, $log, webStomp, alarmKeypad)->
      $scope.keypad = alarmKeypad.query(null,{isArray:false, scope:$scope})

      $scope.click = ()->
        modalInstance = $modal.open AlarmModal $scope.keypad, "sm"

        modalInstance.result.then (command)->
          webStomp.client.send "/exchange/alarm.cmd", null, command
        , ->
          $log.info('Modal dismissed at: ' + new Date());

      $scope.isArmed = ->
        leds = $scope.keypad.data.leds
        (leds['ARMED STAY'] || leds['ARMED (ZERO ENTRY DELAY)'] || leds['ARMED AWAY'])

      $scope.getClass = ->
        if _.isEmpty $scope.keypad
          return ""
        else if $scope.isArmed()
          return "text-danger"
        else
          return "text-success"

      null