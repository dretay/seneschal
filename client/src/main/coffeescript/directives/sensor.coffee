define [
    'd/directives'
    'm/applianceMixin'
    'jquery'
    'underscore'
    'ejs/templates'
  ],
(directives, applianceMixin, $, _, templates) ->
  'use strict'

  directives.directive 'sensor', ->
    restrict: 'E'
    replace: false
    template: templates['appliance']
    scope:
      appliance: "="
    controller: ($scope, $injector, $timeout)->
      $scope._getDisplayLabel = ->
        "#{$scope.appliance.data['S_TEMP'].value}°\n #{$scope.appliance.data['S_HUM'].value}%"

      $scope.innerClassMap =
        "text-center": ->true

      #mix in common appliance functions
      $injector.invoke(applianceMixin, @, {$scope: $scope})

