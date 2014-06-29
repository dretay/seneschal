define [
  'd/directives'
  'jquery'
  'underscore'
],
(directives, $, _) ->
  'use strict'

  directives.directive 'alarmZone', ->
    restrict: 'E'
    replace: false
    templateUrl: '/html/directives/alarmZone.html'
    scope:
      zone: "="

    controller: ($scope, $injector, $timeout)->
      $scope.getClass= ->
        delta = moment.duration(moment() - $scope.zone.timestamp)
        if $scope.zone.open then "progress-bar progress-bar-danger"
        else if delta.asHours() > 1 then "progress-bar progress-bar-success"
        else "progress-bar progress-bar-warning"

      $scope.pending = false


      $scope.getZoneLabel = ->
        minutes = Math.floor(moment.duration(moment() - $scope.zone.timestamp).asMinutes())
        if minutes > 99 then "99" else minutes

      $scope.getTooltip = -> "Last opened #{moment.duration($scope.zone.timestamp - moment()).humanize(true)}"

      $scope.getStyle = ->
        "left": "#{$scope.zone.location.left}%"
        "top": "#{$scope.zone.location.top}%"
        "width": "#{$scope.zone.dimensions.width}%"
        "height": "#{$scope.zone.dimensions.height}%"

      $scope.update = (name)->
          $scope.light.status = !$scope.light.status
          $scope.pending = true
          $scope.light.update().then ->
            $scope.pending = false
      null