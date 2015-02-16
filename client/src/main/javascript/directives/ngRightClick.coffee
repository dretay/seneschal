define [
    'd/directives'
    'jquery'
    'underscore'
  ],
(directives, $, _) ->
  'use strict'

  directives.directive 'ngRightClick', ($parse)->
    (scope, element, attrs)->
      fn = $parse attrs.ngRightClick
      element.bind 'contextmenu', (event)->
        scope.$apply ->
          event.preventDefault()
          fn scope, $event:event
