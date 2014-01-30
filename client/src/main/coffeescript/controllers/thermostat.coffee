define [
  'c/controllers'
  'underscore'
  'p/webStomp'
  'f/celsiusToDegrees'
  'f/degreesToCelsius'
],
(controllers, _) ->
  'use strict'

  controllers.controller 'thermostat', ['$scope', '$timeout', 'webStomp', '$filter', ($scope, $timeout, webStomp, $filter) ->
    $scope.$parent.cfg.pageTitle = "Thermostat"
    $scope.targetTemperature = "---"
    $scope.currentTemperature = ""
    $scope.autoAway = ""
    $scope.targetTemperatureType = ""
    webStomp.getClient($scope.$parent.cfg.token).then (client)=>

      client.subscribe "/exchange/nest.thermostat/fanout", (data)->
        info = JSON.parse data.body
        $scope.targetTemperature = info.target_temperature
        $scope.currentTemperature = info.current_temperature
        $scope.autoAway = info.auto_away
        $scope.targetTemperatureType = info.target_temperature_type
        $scope.$apply()



    $scope.cssFromThermostatMode = ->
      if $scope.targetTemperatureType == "heat"
        "color-circle-heat"
      else
        "color-circle-cool"
    $scope.changeTemperature= (adjustment)->
        newTemp = $filter('degreesToCelsius')($filter('celsiusToDegrees')($scope.targetTemperature) + adjustment)

        $scope.targetTemperature = newTemp

        $timeout ->
          if newTemp == $scope.targetTemperature
            webStomp.then (client)=>
              client.send "/amq/queue/nest.thermostat",null, $filter('celsiusToDegrees')($scope.targetTemperature)
        , 2000

  ]