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
      $scope._click = (size)->
        $modal.open ThermostatModal $scope.appliance, "lg"

      $scope.innerClassMap =
        "thermostatCoolIcon": ->$scope.appliance.data.hvac_mode == "cool"
        "thermostatHotIcon": ->$scope.appliance.data.hvac_mode != "cool"

      $scope._getDisplayLabel = ->
        "#{$scope.appliance.data.ambient_temperature_f}°"

      $scope._getInnerStyle = ->
        "padding-left": "60%"
        "padding-top": "25%"
        "padding-bottom": "25%"

      #mix in common appliance functions
      $injector.invoke(applianceMixin, @, {$scope: $scope})
