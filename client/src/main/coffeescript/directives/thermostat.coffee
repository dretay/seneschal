define [
  'd/directives'
  'jquery'
  'underscore'
  's/nest'
  'p/webStomp'
  'f/celsiusToDegrees'
  'f/degreesToCelsius'
],
(directives, $, _) ->
  'use strict'

  directives.directive 'thermostat', ->
    restrict: 'E'
    replace: false
    templateUrl: '/html/directives/thermostat.html'
    scope:
      thermostat: "="

    controller: ($scope, $injector, $modal, $log)->

      $scope.openThermostat= (size)->
        modalInstance = $modal.open
          templateUrl: '/html/modals/thermostatModal.html'
          controller: ($scope, $modalInstance, nest, webStomp, defaultThermostat, $timeout, $filter)->

            #TODO: this should be part of some over-arching mechanic...
            $scope.$on '$destroy', -> webStomp.client.unsubscribe nest.subscriptionHandler.id

            $scope.innerRadialStyle = (temp)->
              tempToRotation = (temp)-> (temp-32) * 3.789 -144
              "-webkit-transform": "rotate(#{tempToRotation(temp)}deg) translateY(-5.7em)"
              "-moz-transform": "rotate(#{tempToRotation(temp)}deg) translateY(-5.7em)"
              "-o-transform": "rotate(#{tempToRotation(temp)}deg) translateY(-5.7em)"
              "-ms-transform": "rotate(#{tempToRotation(temp)}deg) translateY(-5.7em)"
              "transform": "rotate(#{tempToRotation(temp)}deg) translateY(-5.7em)"
            $scope.radialStyle = (temp)->
              tempToRotation = (temp)-> (temp-32) * 3.789 -144
              "-webkit-transform": "rotate(#{tempToRotation(temp)}deg) translateY(-12.7em)"
              "-moz-transform": "rotate(#{tempToRotation(temp)}deg) translateY(-12.7em)"
              "-o-transform": "rotate(#{tempToRotation(temp)}deg) translateY(-12.7em)"
              "-ms-transform": "rotate(#{tempToRotation(temp)}deg) translateY(-12.7em)"
              "transform": "rotate(#{tempToRotation(temp)}deg) translateY(-12.7em)"

            $scope.isAway = ->
              $scope.getThermostat().away != 'home'
            $scope.defaultThermostat = defaultThermostat
            $scope.targetTemperature = defaultThermostat.data.target_temperature_f
            $scope.nest = nest.query({}, false)
            $scope.changeTemperature= (adjustment)->

              $scope.targetTemperature += adjustment

              newTemp = $scope.targetTemperature

              $timeout ->
                if newTemp == $scope.targetTemperature
                  $scope.nest.update
                    targetTemperature: $scope.targetTemperature
                    device_id: $scope.getThermostat().data.device_id
              , 2000
            $scope.cssFromThermostatMode = ->
              if $scope.getThermostat().data.hvac_mode == "cool"
                "color-circle-cool"
              else
                "color-circle-heat"

            $scope.getThermostat = ->
              if $scope.nest.thermostats && $scope.nest.thermostats.length > 0
                $scope.nest.thermostats[0]
              else
                $scope.defaultThermostat
            $scope.ok = ->
                $modalInstance.close null

            $scope.cancel = ->
              $modalInstance.dismiss('cancel')
          size: size
          resolve:
            defaultThermostat: -> $scope.thermostat



      $scope.getClass= -> ""


      $scope.getStyle = ->
        "left": "#{$scope.thermostat.location.left}%"
        "top": "#{$scope.thermostat.location.top}%"

      null
