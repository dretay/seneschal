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
      host: "="
      token: "="
      thumbnail: "="
      inverted: "="
    controller: ($scope, $injector, $timeout)->
      $scope.proto = "https://"
      $scope.stream = '/videostream.cgi'
      $scope.control = '/decoder_control.cgi'

      $scope.getFramerate = ->
        if $scope.thumbnail then return 15
        return 0
      $scope.getCameraClass = ->
        unless $scope.thumbnail then return "cameraImage" else return "cameraThumbnail"

      $scope.getEncodedToken = ->
        return encodeURIComponent $scope.token
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
        if $scope.inverted then direction = invertDirection(direction)
        $scope.cameraCmd(cameraCmds[direction].start)

      $scope.endCameraMove = (direction)->
        if $scope.inverted then direction = invertDirection(direction)
        $scope.cameraCmd(cameraCmds[direction].end)

      $scope.cameraCmd = (command)->
        $.ajax({
          url: "#{$scope.proto}#{$scope.host}#{$scope.control}"
          data:
            command: command
            token: $scope.token
        }).done ->
          null
