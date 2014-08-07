define [
    'c/controllers'
    'underscore'
    's/router'
  ],
(controllers, _) ->
  'use strict'

  controllers.controller 'router', ['$scope', '$rootScope', '$timeout', '$routeParams', 'router', 'ngTableParams', ($scope, $rootScope, $timeout, $routeParams, router, ngTableParams) ->

    router.token = $routeParams.token
    $scope.clients = router.query()


  ]