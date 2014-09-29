define [
    'angular'
    's/services'
    'jquery'
  ],
(angular, services, $) ->
  'use strict'

  services.factory 'authorization', ['$http', ($http)->
    login: (credentials)->
      $http.post("https://www.drewandtrish.com/login", credentials);
  ]