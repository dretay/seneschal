define [
    'd/directives'
    'jquery'
    'underscore'
    's/alarmKeypad'
  ],
(directives, $, _) ->
  'use strict'

  directives.directive 'alarmKeypadStatus', ->
    restrict: 'E'
    replace: false
    template: "<span>{{alarmStatusMsg()}}</span>"

    controller: ($scope, $log, alarmKeypad)->
      $scope.alarmKeypad = alarmKeypad.query(null,{isArray:false, scope:$scope})

      $scope.alarmStatusMsg = ->
        if not _.isEmpty $scope.alarmKeypad
          leds = $scope.alarmKeypad.data.leds
          if leds['ARMED STAY'] then return "Armed: STAY"
          else if leds['ARMED (ZERO ENTRY DELAY)'] then return "Armed: NO DELAY"
          else if leds['ARMED AWAY'] then return "Armed: AWAY"
          else if leds['READY'] then return "Disarmed: READY TO ARM"
          else return "Disarmed: UNABLE TO ARM"
        return "Loading..."