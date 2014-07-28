define [
  'd/directives'
  'm/applianceMixin'
  'jquery'
  'underscore'
  'modals/AlarmModal'
],
(directives, applianceMixin, $, _, AlarmModal) ->
  'use strict'

  directives.directive 'alarmKeypad', ->
    restrict: 'E'
    replace: false
    templateUrl: '/html/directives/appliance.html'
    scope:
      appliance: "="

    controller: ($scope, $injector, $timeout, $modal, $log, webStomp)->

      $scope.innerClassMap =
        "fa fa-lock fa-5x" : -> $scope.isArmed()
        "fa fa-unlock fa-5x" : -> !$scope.isArmed()

      $scope._click= ()->
        modalInstance = $modal.open AlarmModal $scope.appliance, "sm"

        modalInstance.result.then (command)->
            webStomp.client.send "/exchange/alarm.cmd",null, command
        ,->
          $log.info('Modal dismissed at: ' + new Date());

      $scope.isArmed = ()->
        leds = $scope.appliance.data.leds
        (leds['ARMED STAY'] || leds['ARMED (ZERO ENTRY DELAY)'] || leds['ARMED AWAY'])


      #mix in common appliance functions
      $injector.invoke(applianceMixin, @, {$scope: $scope})