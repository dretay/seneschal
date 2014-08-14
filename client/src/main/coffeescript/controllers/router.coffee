define [
    'c/controllers'
    'underscore'
    's/router'
    'f/timestampAge'
  ],
(controllers, _) ->
  'use strict'

  controllers.controller 'router', ['$scope', '$rootScope', '$timeout', '$routeParams', 'router', 'ngTableParams',
    ($scope, $rootScope, $timeout, $routeParams, router, ngTableParams) ->
      $scope.clients = router.query()


  ]