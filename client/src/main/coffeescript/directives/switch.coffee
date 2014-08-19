define [
    'd/directives'
    'm/applianceMixin'
    'jquery'
    'underscore'
  ],
(directives, applianceMixin, $, _) ->
  'use strict'

  directives.directive 'switch', ->
    restrict: 'E'
    replace: false
    templateUrl: '/html/directives/appliance.html'
    scope:
      appliance: "="
    controller: ($scope, $injector, $timeout)->
      $scope.pending = false

      if _.isFunction $scope.appliance.getOuterClassMap then $scope.outerClassMap = $scope.appliance.getOuterClassMap($scope)


      $scope._getTooltip = ->
        $scope.appliance.name

      $scope._click = (name)->
        $scope.pending = true
        $scope.appliance.update().then ->
          $scope.pending = false

      #mix in common appliance functions
      $injector.invoke(applianceMixin, @, {$scope: $scope})

