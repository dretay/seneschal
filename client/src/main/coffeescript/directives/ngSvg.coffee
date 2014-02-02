define [
  'd/directives'
  'jquery'
  'underscore'
  'jquerySvg'
],
(directives, $, _) ->
  'use strict'

  directives.directive 'ngSvg', ->
    restrict: 'E'
    scope: true
    transclude: true
    replace: true
    template: '<div ng-transclude></div>'
    controller: ($element, $scope)->
      $scope.that = this
      null
    link: (scope,element, attrs)->
      $(element).svg
        onLoad: (svg)->
          # svg.attr('preserveAspectRatio', 'xMinYMin meet')
          svg.load '/stylesheets/img/mainlevel.svg',
            addTo: true
            onLoad: ->
              console.log "LOADED!!!"
          scope.that.svg = svg
          scope.that.paths = svg.defs('paths');
          scope.that.shapeGroup = svg.group({class: 'shapes'});
      null


