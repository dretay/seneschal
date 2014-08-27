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

      $scope._getTooltip = ->
        "Last opened #{moment.duration($scope.appliance.timestamp - moment()).humanize(true)}"
      $scope._click = ()->
        $scope.appliance.update()

      #mix in common appliance functions
      $injector.invoke(applianceMixin, @, {$scope: $scope})