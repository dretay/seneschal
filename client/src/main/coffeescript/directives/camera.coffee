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
      $scope.cameraCmd = (command)->
        $.ajax({
          url: "#{$scope.proto}#{$scope.host}#{$scope.control}"
          data:
            command: command
            token: $scope.token
        }).done ->
          null
