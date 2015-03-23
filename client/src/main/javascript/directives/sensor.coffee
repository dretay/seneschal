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
    template: templates['appliance']
    scope:
      appliance: "="
    controller: ($scope, $injector, $timeout, $compile, $modal)->
      $scope._getDisplayLabel = ->
        if $scope.appliance.data['S_TEMP']? and $scope.appliance.data['S_HUM']?
          "#{$scope.appliance.data['S_TEMP'].real_value}° #{$scope.appliance.data['S_HUM'].real_value}%"
        else if $scope.appliance.data['S_TEMP']?
          "#{$scope.appliance.data['S_TEMP'].real_value}°"

#      $scope.innerClassMap =
#        "label label-primary": ->true

      $scope._getOuterStyle = ->
        "width": "5em"
      $scope._getInnerStyle = ->
        "border-radius": "5px"
        "margin-top": "5em"
        "color": "white"

      $scope._getTooltip = ->
        $scope.appliance.name


      #mix in common appliance functions
      $injector.invoke(applianceMixin, @, {$scope: $scope})

