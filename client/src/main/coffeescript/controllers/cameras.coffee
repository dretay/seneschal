define [
  'c/controllers'
  'd/camera'
],
(controllers, _, $) ->
  'use strict'

  controllers.controller 'cameras', ['$scope', '$timeout', 'lights', ($scope, $timeout, lights) ->
    $scope.$parent.cfg.pageTitle = "Cameras"

    $scope.cameras = [
      {host: "www.drewandtrish.com:9000/cameras/livingroom", token: $scope.$parent.cfg.token}
      {host: "www.drewandtrish.com:9000/cameras/basement", token: $scope.$parent.cfg.token}
      {host: "www.drewandtrish.com:9000/cameras/frontdoor", token: $scope.$parent.cfg.token}
      {host: "www.drewandtrish.com:9000/cameras/porch", token: $scope.$parent.cfg.token}

    ]

    $scope.setActiveCamera = (index)->
      $scope.activeCamera = index


    $scope.setActiveCamera(0)
  ]