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

  controllers.controller 'lights', ['$scope', '$timeout', 'lights', ($scope, $timeout, lights) ->
    lights.token = $scope.$parent.cfg.token
    $scope.lights = lights.query()
    $scope.$parent.cfg.pageTitle = "Lights"

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
