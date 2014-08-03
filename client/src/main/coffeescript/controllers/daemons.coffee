define [
  'c/controllers'
  'underscore'
  's/supervisor'
  'f/splitOnNewline'
],
(controllers, _) ->
  'use strict'

  controllers.controller 'daemons', ['$scope', '$rootScope', '$timeout', '$routeParams', 'supervisor', ($scope, $rootScope, $timeout, $routeParams, supervisor) ->

    supervisor.token = $routeParams.token
    $scope.processes = supervisor.query()
    $scope.get_log= (process)->
      $scope.log = supervisor.query
        operation: "read_log"
        processname: process.name
        limit: "1024"
      ,false
    $scope.start_task = (process)->
      process.update
        operation: "task_start"
    $scope.restart_task= (process)->
      process.update
        operation: "task_restart"
    $scope.stop_task= (process)->
      process.update
        operation: "task_stop"


  ]