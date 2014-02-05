define [
  'c/controllers'
  'underscore'
  'jquery'
  'c/lights'
  's/lights'
  'd/light'
  'f/lightsOnFloor'
],
(controllers, _, $) ->
  'use strict'

  controllers.controller 'lights', ['$scope', '$timeout', '$routeParams', 'lights', ($scope, $timeout, $routeParams, lights) ->
    lights.token = $routeParams.token
    $scope.lights = lights.query()
    $scope.loading = true
    $scope.$watch 'lights', (newVal, oldVal)->
      $scope.loading = if newVal.length > 0 then false else true
    , true

    $scope.isActiveFloor = (floor)->
      if floor == $scope.activeFloor then "selected" else ""

    $scope.floors =
      basement:
        name: "basement"
        url: '/stylesheets/img/basement.svg'

      mainFloor:
        name: "mainFloor"
        url: '/stylesheets/img/mainlevel.svg'

      secondFloor:
        name: "secondFloor"
        url: '/stylesheets/img/secondfloor.svg'

    $scope.activeFloor = $scope.floors.mainFloor
  ]
