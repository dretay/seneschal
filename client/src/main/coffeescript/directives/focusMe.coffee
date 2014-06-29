define [
  'd/directives'
  'jquery'
  'underscore'
],
(directives, $, _) ->
  'use strict'

  directives.directive 'focusMe', ($timeout, $parse)->
    link: (scope, element, attrs)->
      model = $parse(attrs.focusMe)
      scope.$watch model, (value)->
        if(value == true)  then $timeout -> element[0].focus()
      element.bind 'blur', ->
         scope.$apply model.assign(scope, false)
