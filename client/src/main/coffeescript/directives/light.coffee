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
      $scope.getSpinnerClass = ->
        if $scope.light.status
          "ui-spinner-right"
        else
          ""
      $scope.update = (name)->
        $timeout ->
          $scope.pending = true
          $scope.light.update().then ->
            $scope.pending = false
        ,50
      null
      # $injector.invoke(commonBarItem, @, {$scope: $scope})

