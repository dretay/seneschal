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
    template: "<span class='fa fa-lock' ng-class='getClass()' ng-click='click()'></span><span style='padding-left: 0.7em;color: black'>{{getLabel()}}</span>"
    scope:
      listView: "@"

    controller: ($scope, $injector, $timeout, $modal, $log, webStomp, alarmKeypad)->
      $scope.keypad = alarmKeypad.query(null,{isArray:false, scope:$scope})

      $scope.click = ()->
        modalInstance = $modal.open AlarmModal $scope.keypad, "sm"

        modalInstance.result.then (command)->
          webStomp.client.send "/exchange/alarm.cmd", null, command
        , ->
          $log.info('Modal dismissed at: ' + new Date());

      $scope.getLabel = ->
        if $scope.listView == "true" then return $scope.keypad.name else return ""
      $scope.isArmed = ->
        leds = $scope.keypad.data.leds
        (leds['ARMED STAY'] || leds['ARMED (ZERO ENTRY DELAY)'] || leds['ARMED AWAY'])

      $scope.getClass = ->
        if _.isEmpty $scope.keypad
          return ""
        else if $scope.isArmed()
          if $scope.listView == "true" then return "fa-2x text-danger" else  return "fa-stack-1x text-danger"
        else
          if $scope.listView == "true" then return "fa-2x text-success" else  return "fa-stack-1x text-success"

      null