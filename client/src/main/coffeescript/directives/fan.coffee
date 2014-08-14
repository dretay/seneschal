define [
    'd/directives'
    'm/applianceMixin'
    'jquery'
    'underscore'
  ],
(directives, applianceMixin, $, _) ->
  'use strict'

  directives.directive 'fan', ->
    restrict: 'E'
    replace: false
    templateUrl: '/html/directives/appliance.html'
    scope:
      appliance: "="
    controller: ($scope, $injector, $timeout)->
      $scope.pending = false

      $scope.innerClassMap =
        "fa fa-spinner fa-spin fa-3x": ->
          $scope.pending
        "fan": ->
          !$scope.pending
      $scope.outerClassMap =
        "fa fa-spin": ->
          $scope.appliance.status == true

      $scope._getTooltip = ->
        $scope.appliance.name

      $scope._click = (name)->
        $scope.pending = true
        $scope.appliance.update().then ->
          $scope.pending = false

      #mix in common appliance functions
      $injector.invoke(applianceMixin, @, {$scope: $scope})

