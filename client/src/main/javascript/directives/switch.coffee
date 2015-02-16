define [
    'd/directives'
    'm/applianceMixin'
    'jquery'
    'underscore'
    'ejs/templates'
  ],
(directives, applianceMixin, $, _, templates) ->
  'use strict'

  directives.directive 'switch', ->
    restrict: 'E'
    replace: false
    template: templates['appliance']
    scope:
      appliance: "="
    controller: ($scope, $injector, $interval)->

      $scope.pending = false

      $scope._getTooltip = ->
        $scope.appliance.name

      $scope._click = ()->
        $scope.pending = true
        $scope.appliance.update().then ->
          $scope.pending = false

      #mix in common appliance functions
      $injector.invoke(applianceMixin, @, {$scope: $scope})

