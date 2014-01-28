define [
  'd/directives'
  'jquery'
  'underscore'
],
(directives, $, _) ->
  'use strict'

  directives.directive 'clock', ->
    restrict: 'E'
    replace: false
    templateUrl: '/html/directives/clock.html'

