define [
  'c/controllers'
],
(controllers) ->
  'use strict'

  controllers.controller 'main', ['$scope', '$routeParams', '$location', ($scope, $routeParams, $location) ->

    $scope.routeParams = $routeParams
    $scope.location = $location
    $scope.isNavItemActive = (title)->
      if location.hash.match(new RegExp(title,'gi')) then "active"
  ]