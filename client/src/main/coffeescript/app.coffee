define [
  'angular'
  'angularRoute'
  'angularResource'
  'c/controllers'
  'd/directives'
  'f/filters'
  'p/providers'
  'r/resources'
  's/services'
], (angular) ->
  'use strict'
  angular.module 'app', [
      'ngResource'
      'ngRoute'
      'controllers'
      'directives'
      'filters'
      'providers'
      'resources'
      'services'
  ]