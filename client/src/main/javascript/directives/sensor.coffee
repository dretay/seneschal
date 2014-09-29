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
    template: templates['sensor']
    scope:
      appliance: "="
    controller: ($scope, $injector, $timeout, $compile)->
      $scope._getDisplayLabel = ->
        "#{$scope.appliance.data['S_TEMP'].value}° #{$scope.appliance.data['S_HUM'].value}%"

      $scope.innerClassMap =
        "label label-primary": ->true

      $scope._getInnerStyle = ->
        "border-radius": "5px"
        "margin-top": "5em"

      $scope.myData = [
        { value : 50, color : "#F7464A" },
        { value : 90, color : "#E2EAE9" },
        { value : 75, color : "#D4CCC5" },
        { value : 30, color : "#949FB1"}
      ]



      #mix in common appliance functions
      $injector.invoke(applianceMixin, @, {$scope: $scope})

