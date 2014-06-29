define [
  'd/directives'
  'm/commonBarItem'
  'jquery'
  'underscore'
],
(directives, commonBarItem, $, _) ->
  'use strict'

  directives.directive 'light', ->
    restrict: 'E'
    replace: false
    templateUrl: '/html/directives/light.html'
    scope:
      light: "="
    controller: ($scope, $injector, $timeout)->
      $scope.pending = false
      $scope.getIconClass= ->
        if $scope.pending
          "fa-spinner fa-spin fa-2x"
        else
          "fa-lightbulb-o fa-3x"

      $scope.getClass= ->
        if $scope.light.status
          "lightBulb-on"
        else
          "lightBulb-off"

      $scope.getStyle = ->
        "left": "#{$scope.light.location.left}%"
        "top": "#{$scope.light.location.top}%"

      $scope.update = (name)->
          # $scope.light.status = !$scope.light.status
          $scope.pending = true
          $scope.light.update().then ->
            $scope.pending = false
      null
      # $injector.invoke(commonBarItem, @, {$scope: $scope})

