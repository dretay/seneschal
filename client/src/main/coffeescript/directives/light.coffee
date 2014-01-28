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
      $scope.update = (name)->
        console.log name
        $scope.light.update()
      null
      # $injector.invoke(commonBarItem, @, {$scope: $scope})

