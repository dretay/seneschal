define [
  'd/directives'
  'm/applianceMixin'
  'jquery'
  'underscore'
  'modals/ThermostatModal'
  's/nest'
  'p/webStomp'
],
(directives, applianceMixin, $, _, ThermostatModal) ->
  'use strict'

  directives.directive 'thermostat', ->
    restrict: 'E'
    replace: false
    templateUrl: '/html/directives/appliance.html'
    scope:
      appliance: "="

    controller: ($scope, $injector, $modal, $log)->

      $scope._click= (size)-> $modal.open ThermostatModal $scope.appliance, "lg"

      $scope.innerClassMap =
        "fa fa-sort fa-2x" : -> true

      $scope._getDisplayLabel = -> "#{$scope.appliance.data.ambient_temperature_f}°"

      #mix in common appliance functions
      $injector.invoke(applianceMixin, @, {$scope: $scope})
