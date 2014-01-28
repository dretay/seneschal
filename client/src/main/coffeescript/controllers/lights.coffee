define [
  'c/controllers'
  'underscore'
  'jquery'
  'c/lights'
  's/lights'
  'd/light'
],
(controllers, _, $) ->
  'use strict'

  controllers.controller 'lights', ['$scope', '$timeout', 'lights', ($scope, $timeout, lights) ->
    lights.token = $scope.$parent.cfg.token
    $scope.lights = lights.query()
    $scope.$parent.cfg.pageTitle = "Lights"

  ]