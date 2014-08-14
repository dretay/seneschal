define [
  'c/controllers'
  'd/camera'
],
(controllers, _, $) ->
  'use strict'

  controllers.controller 'cameras', ['$scope', '$timeout', '$routeParams', 'lights', ($scope, $timeout, $routeParams ,lights) ->
    # $scope.$parent.cfg.pageTitle = "Cameras"


    $scope.cameras = [
      {
        videoUrl: "www.drewandtrish.com:9000/cameras/127.0.0.1/9100"
        controlUrl: "www.drewandtrish.com:9000/cameras/192.168.1.16/8082"
        token: $routeParams.token
      }
      {
        videoUrl: "www.drewandtrish.com:9000/cameras/127.0.0.1/9101"
        controlUrl: "www.drewandtrish.com:9000/cameras/192.168.1.15/8081"
        token: $routeParams.token
      }
      {
        videoUrl: "www.drewandtrish.com:9000/cameras/127.0.0.1/9102"
        controlUrl: "www.drewandtrish.com:9000/cameras/192.168.1.17/8080"
        token: $routeParams.token
      }
      {
        videoUrl: "www.drewandtrish.com:9000/cameras/127.0.0.1/9103"
        controlUrl: "www.drewandtrish.com:9000/cameras/192.168.1.18/8083"
        token: $routeParams.token
        inverted: true
      }
    ]

    $scope.setActiveCamera = (index)->
      $scope.activeCamera = index


    $scope.setActiveCamera(0)
  ]
