define [
  'c/controllers'
  'd/camera'
],
(controllers, _, $) ->
  'use strict'

  controllers.controller 'cameras', ['$scope', '$timeout', '$routeParams', 'lights', ($scope, $timeout, $routeParams ,lights) ->
    # $scope.$parent.cfg.pageTitle = "Cameras"
    $scope.token = $routeParams.token

    $scope.cameras = [
      {host: "www.drewandtrish.com:9000/cameras/livingroom", token: $routeParams.token}
      {host: "www.drewandtrish.com:9000/cameras/basement", token: $routeParams.token}
      {host: "www.drewandtrish.com:9000/cameras/frontdoor", token: $routeParams.token}
      {host: "www.drewandtrish.com:9000/cameras/porch", token: $routeParams.token, inverted: true}

    ]

    $scope.setActiveCamera = (index)->
      $scope.activeCamera = index


    $scope.setActiveCamera(0)
  ]