define [
    'c/controllers'
    's/authorization'
  ],
(controllers) ->
  'use strict'

  controllers.controller 'login', ['$scope', 'authorization', '$location', 'cookieStore', '$timeout', 'webStomp', ($scope, authorization, $location, cookieStore, $timeout, webStomp) ->
    $scope.username = ""
    $scope.password = ""
    $scope.login = ->
      credentials = "username=#{$scope.username}&password=#{$scope.password}"

      success = (data,status,header)->
        cookieStore.put "authentication", data.trim(),
          domain: ".drewandtrish.com"
          path: "/"
          end: new Date(2020, 5, 12)
        $timeout ->
          deferred = $.Deferred()
          webStomp.getClient(deferred, true)
          deferred.then ->
            $location.path '/controls/mainFloor'
            $scope.$apply()
        , 100


      error = ->
        alert "failed to login"

      authorization.login(credentials).success(success).error(error);
  ]