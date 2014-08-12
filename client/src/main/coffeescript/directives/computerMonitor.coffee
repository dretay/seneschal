define [
    'd/directives'
    'm/applianceMixin'
    'jquery'
    'underscore'
  ],
(directives, applianceMixin, $, _) ->
  'use strict'

  directives.directive 'computerMonitor', ->
    restrict: 'E'
    replace: false
    templateUrl: '/html/directives/appliance.html'
    scope:
      appliance: "="
    controller: ($scope, $injector, $timeout)->

      $scope.pending = false

      $scope.outerClassMap =
        "fa fa-spinner fa-spin fa-3x monitor-pending" : ->$scope.pending
        "monitor-on": -> $scope.appliance.status == true
        "monitor-off": -> $scope.appliance.status == false

      $scope._getTooltip = ->
        $scope.appliance.name

      $scope._click = (name)->
        $scope.pending = true
        $scope.appliance.update().then ->
          $scope.pending = false

      #mix in common appliance functions
      $injector.invoke(applianceMixin, @, {$scope: $scope})

