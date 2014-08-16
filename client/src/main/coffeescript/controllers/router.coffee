define [
    'c/controllers'
    'underscore'
    's/router'
    'f/plaintextAge'
    'd/ngSmoothie'
  ],
(controllers, _) ->
  'use strict'

  controllers.controller 'router', ['$scope', '$rootScope', '$timeout', '$routeParams', 'router', 'ngTableParams',
    ($scope, $rootScope, $timeout, $routeParams, router, ngTableParams) ->
      $scope.clients = router.query(null,{scope:$scope})
      $scope.criteria= null
      $scope.setCriteria = (mac)->
        if !$scope.criteria? or mac == $scope.criteria.mac
          $scope.status.open = !$scope.status.open
        $scope.criteria = {mac: mac}
      $scope.tranSeries =
        rx: "number of packets received by the client"
        tx: "number of packets transmitted by the client"

      $scope.qualSeries =
        noise: "dB noise level reported by the client (or -1)"
        rxerr: "number of error packets received by the client"
        signal: "dB signal strength reported by the client (or -1)"
        txerr: "number of error packets transmitted by the client"
      $scope.selectedTask = null
      $scope.status =
        isFirstOpen: true
        isFirstDisabled: false
        open: false
      $scope.oneAtATime = false


  ]