define [
    'c/controllers'
    'underscore'
    's/supervisor'
    'f/splitOnNewline'
  ],
(controllers, _) ->
  'use strict'

  controllers.controller 'daemons', ['$scope', '$rootScope', '$timeout', '$routeParams', 'supervisor', 'ngTableParams',
    ($scope, $rootScope, $timeout, $routeParams, supervisor, ngTableParams) ->
      $scope.processes = supervisor.query()
      $scope.selectedTask = null
      $scope.status =
        isFirstOpen: true
        isFirstDisabled: false
      $scope.oneAtATime = false

      $scope.get_log = (process)->
        if !$scope.selectedTask? or process.name == $scope.selectedTask.name
          $scope.status.open = !$scope.status.open
        $scope.log = supervisor.query
          operation: "read_log"
          processname: process.name
          limit: "1024"
        , false
      $scope.start_task = (process)->
        process.update
          operation: "task_start"
      $scope.restart_task = (process)->
        process.update
          operation: "task_restart"
      $scope.stop_task = (process)->
        process.update
          operation: "task_stop"
      $scope.tableParams = new ngTableParams {
          page: 1
          total: 1
        },
        counts: []
      $scope.selectTask = (task)->
        $scope.selectedTask = task

  ]