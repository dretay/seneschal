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
    template: "<span class='fa' ng-class='getClass()' ng-click='click()'></span><span style='padding-left: 0.7em;color: black'>{{getLabel()}}</span>"
    scope:
      listView: "@"

    controller: ($scope, $injector, $timeout, $modal, $log, webStomp, alarmKeypad)->
      $scope.keypad = alarmKeypad.query(null,{isArray:false, scope:$scope})

      $scope.click = ()->
        modalInstance = $modal.open AlarmModal $scope.keypad, "sm"

        modalInstance.result.then (command)->
          webStomp.client.send "/exchange/eyezon.cmd", null, command
        , ->
          $log.info('Modal dismissed at: ' + new Date());

      $scope.getLabel = ->
        if $scope.listView == "true" then return $scope.keypad.name else return ""
      $scope.isArmed = ->
        leds = $scope.keypad.data.leds
        (leds['ARMED STAY'] || leds['ARMED (ZERO ENTRY DELAY)'] || leds['ARMED AWAY'])

      $scope.getClass = ->
        if _.isEmpty $scope.keypad
          if $scope.listView == "true" then return "" else return "fa-stack-1x"
        else if $scope.isArmed()
          if $scope.listView == "true" then return "fa-2x text-danger fa-lock" else  return "fa-stack-1x text-danger fa-lock"
        else
          if $scope.listView == "true" then return "fa-2x text-success fa-unlock" else  return "fa-stack-1x text-success fa-unlock"

      null