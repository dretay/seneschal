define [
  'd/directives'
  'jquery'
  'underscore'
],
(directives, $, _) ->
  'use strict'

  directives.directive 'camera', ->
    restrict: 'E'
    replace: false
    templateUrl: '/html/directives/camera.html'
    scope:
      camera: "="
    controller: ($scope, $injector, $timeout, $modal, $log)->
      $scope.openCamera= (size)->
        modalInstance = $modal.open
          templateUrl: '/html/modals/cameraModal.html'
          controller: ($scope, $modalInstance, camera)->

            $scope.camera = camera
            $scope.timestamp = new Date().getTime()

            cameraCmds =
              down:
                start: 0
                end: 1
              up:
                start: 2
                end: 3
              left:
                start: 4
                end: 5
              right:
                start: 6
                end: 7

            invertDirection = (direction)->
              switch direction
                  when "left" then return "right"
                  when "right" then return "left"
                  when "up" then return "down"
                  when "down" then return "up"

            $scope.startCameraMove = (direction)->
              if $scope.camera.inverted then direction = invertDirection(direction)
              $scope.cameraCmd(cameraCmds[direction].start)

            $scope.endCameraMove = (direction)->
              if $scope.inverted then direction = invertDirection(direction)
              $scope.cameraCmd(cameraCmds[direction].end)
            $scope.cameraCmd = (command)->
              $.ajax({
                url: "#{$scope.camera.proto}#{$scope.camera.controlUrl}#{$scope.camera.control}"
                data:
                  command: command
                  token: $scope.camera.token
              }).done ->
                null


            $scope.close = ->
              $modalInstance.close null

            $scope.cancel = ->
              $modalInstance.dismiss('cancel')
          size: size
          resolve:
            camera: -> $scope.camera

      $scope.getClass= ->
        if $scope.camera.status
          "lightBulb-on"
      $scope.getStyle = ->
        "left": "#{$scope.camera.location.left}%"
        "top": "#{$scope.camera.location.top}%"
        "-webkit-transform": "rotate(#{$scope.camera.rotation}deg)"


      $scope.getCameraClass = ->
        unless $scope.thumbnail then return "cameraImage" else return "cameraThumbnail"





