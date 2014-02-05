define [
  'c/controllers'
  'underscore'
  'p/webStomp'
  'f/oddLengthString'
],
(controllers, _) ->
  'use strict'

  controllers.controller 'alarm', ['$scope', '$rootScope', '$timeout', '$routeParams', 'webStomp', ($scope, $rootScope, $timeout, $routeParams, webStomp) ->
    # $scope.$parent.cfg.pageTitle = "Alarm"
    $scope.alarmLineOne = "88888888888888888888888888888888"
    $scope.alarmLineTwo = "88888888888888888888888888888888"
    $scope.alarmCmd = ""
    stompClient = null
    subscriptions = []
    webStomp.getClient($routeParams.token).then (client)=>
      stompClient = client
      subscriptions.push client.subscribe "/exchange/eyezon.alarm/fanout", (data)->
        tokens = JSON.parse(data.body).split(",")
        $scope.alarmLineOne = unless _.isUndefined tokens[5] then tokens[5] else $scope.alarmLineOne
        $scope.alarmLineTwo = unless _.isUndefined tokens[6] then tokens[6] else $scope.alarmLineTwo
        $rootScope.$apply()

    $scope.$on '$destroy', ->
      stompClient.unsubscribe subscription.id for subscription in subscriptions

    $scope.keystroke= (key)->
        updatedCmd = ($scope.alarmCmd += key)
        $timeout ->
          if updatedCmd == $scope.alarmCmd
            stompClient.send "/amq/queue/eyezon.alarm",null, $scope.alarmCmd
            $scope.alarmCmd = ""
        , 2000

  ]