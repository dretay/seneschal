define [
    'd/directives'
    'jquery'
    'underscore'
  ],
(directives, $, _) ->
  'use strict'

  directives.directive 'garageDoor', ->
    restrict: 'E'
    replace: false
    templateUrl: '/html/directives/garageDoor.html'
    scope:
      door: "="

    controller: ($scope, $injector, $timeout)->
      $scope.getClass = ()->
        if $scope.door.status == "open" then "progress-bar progress-bar-danger" else "progress-bar progress-bar-success"

      $scope.getTooltip = ->
        ""

      $scope.getStyle = ->
        "left": "#{$scope.door.location.left}%"
        "top": "#{$scope.door.location.top}%"
        "width": "#{$scope.door.dimensions.width}%"
        "height": "#{$scope.door.dimensions.height}%"

      $scope._click = ()->
        $scope.door.update()
      null