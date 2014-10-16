define [
    'd/directives'
    'm/applianceMixin'
    'jquery'
    'underscore'
    'ejs/templates'
  ],
(directives, applianceMixin, $, _, templates, SensorHistoryModal) ->
  'use strict'

  directives.directive 'sensor', ->
    restrict: 'E'
    replace: false
    template: templates['sensor']
    scope:
      appliance: "="
    controller: ($scope, $injector, $timeout, $compile, $modal)->
      $scope._getDisplayLabel = ->
        "#{$scope.appliance.data['S_TEMP'].real_value}° #{$scope.appliance.data['S_HUM'].real_value}%"

#      $scope.innerClassMap =
#        "label label-primary": ->true

      $scope._getInnerStyle = ->
        "border-radius": "5px"
        "margin-top": "5em"
        "color": "white"


      #mix in common appliance functions
      $injector.invoke(applianceMixin, @, {$scope: $scope})

