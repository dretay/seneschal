define [
  'c/controllers'
  'underscore'
  'p/webStomp'
  'f/oddLengthString'
],
(controllers, _) ->
  'use strict'

  controllers.controller 'alarm', ['$scope', '$timeout', 'webStomp', ($scope, $timeout, webStomp) ->
    $scope.$parent.cfg.pageTitle = "Alarm"
    $scope.alarmLineOne = ""
    $scope.alarmLineTwo = ""
    $scope.alarmCmd = ""
    webStomp.getClient($scope.$parent.cfg.token).then (client)=>
      client.subscribe "/exchange/eyezon.alarm/fanout", (data)->
        tokens = JSON.parse(data.body).split(",")
        $scope.alarmLineOne = unless _.isUndefined tokens[5] then tokens[5] else $scope.alarmLineOne
        $scope.alarmLineTwo = unless _.isUndefined tokens[6] then tokens[6] else $scope.alarmLineTwo

        $scope.$apply()

    $scope.keystroke= (key)->
        updatedCmd = ($scope.alarmCmd += key)
        $timeout ->
          if updatedCmd == $scope.alarmCmd
            webStomp.then (client)=>
              client.send "/amq/queue/eyezon.alarm",null, $scope.alarmCmd
              $scope.alarmCmd = ""
        , 2000

  ]