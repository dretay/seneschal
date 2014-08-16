define [
    'd/directives'
    'm/applianceMixin'
    'jquery'
    'underscore'
  ],
(directives, applianceMixin, $, _) ->
  'use strict'

  directives.directive 'alarmZone', ->
    restrict: 'E'
    replace: false
    templateUrl: '/html/directives/appliance.html'
    scope:
      appliance: "="

    controller: ($scope, $injector, $timeout)->
      $scope.delta = moment.duration(moment() - $scope.appliance.timestamp)

      $scope.outerClassMap =
        " progress-bar progress-bar-danger alarmZone": ->
          $scope.appliance.open
        " progress-bar progress-bar-success alarmZone": ->
          $scope.delta.asHours() > 1
        " progress-bar progress-bar-warning alarmZone": ->
          true


      $scope._getTooltip = ->
        "Last opened #{moment.duration($scope.appliance.timestamp - moment()).humanize(true)}"


      #mix in common appliance functions
      $injector.invoke(applianceMixin, @, {$scope: $scope})