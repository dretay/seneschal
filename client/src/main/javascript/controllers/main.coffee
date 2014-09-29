define [
    'c/controllers'
  ],
(controllers) ->
  'use strict'

  controllers.controller 'main', ['$scope', '$routeParams', '$location', ($scope, $routeParams, $location) ->
    $scope.routeParams = $routeParams
    $scope.location = $location
    $scope.isChildNavItemActive = (title)->
      if location.hash.match(new RegExp(title, 'gi')) then "disabled"
    $scope.isNavItemActive = (title)->
      if location.hash.match(new RegExp(title, 'gi')) then "active"
  ]