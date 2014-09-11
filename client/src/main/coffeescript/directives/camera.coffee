define [
    'd/directives'
    'm/applianceMixin'
    'modals/CameraModal'
    'jquery'
    'underscore'
    'ejs/templates'
  ],
(directives, applianceMixin, CameraModal, $, _, templates) ->
  'use strict'

  directives.directive 'camera', ->
    restrict: 'E'
    replace: false
    template: templates['appliance']
    scope:
      appliance: "="
    controller: ($scope, $injector, $timeout, $modal, $log)->
      $scope._click = ()->
        $modal.open CameraModal $scope.appliance, "lg"

      $scope.outerClassMap =
        "securityCamera": -> true

      #mix in common appliance functions
      $injector.invoke(applianceMixin, @, {$scope: $scope})





