define [
  'd/directives'
  'm/applianceMixin'
  'modals/CameraModal'
  'jquery'
  'underscore'
],
(directives, applianceMixin, CameraModal, $, _) ->
  'use strict'

  directives.directive 'camera', ->
    restrict: 'E'
    replace: false
    templateUrl: '/html/directives/appliance.html'
    scope:
      appliance: "="
    controller: ($scope, $injector, $timeout, $modal, $log)->
      $scope._click= ()-> $modal.open CameraModal $scope.appliance, "lg"

      $scope.innerClassMap =
        "securityCamera" : ->true

      #mix in common appliance functions
      $injector.invoke(applianceMixin, @, {$scope: $scope})





