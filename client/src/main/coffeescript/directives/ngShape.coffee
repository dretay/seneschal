define [
  'd/directives'
  'jquery'
  'underscore'
  'jquerySvg'
],
(directives, $, _) ->
  'use strict'

  directives.directive 'ngShape', ($compile)->

    createPathDefinition= ($scope, ngSvg)->
      id = $scope.model.id + '_clipPath'
      clipPathParent = ngSvg.svg.clipPath ngSvg.paths, id

      path = ngSvg.svg.path clipPathParent, '',
        'id': '{{model.id}}'
        'ng-attr-d': '{{model.path}}'

      return path

    drawShape= ($scope, ngSvg)->
      parentGroup = ngSvg.svg.group ngSvg.shapeGroup,
        transform: 'translate({{model.left}},{{model.top}})',
        'clip-path': 'url({{"#" + model.id + "_clipPath"}})'


      shapeForeground = ngSvg.svg.use parentGroup, '',
        'ng-href': '{{"#" + model.id}}'
        'fill': '{{model.backgroundColor}}'
        'stroke': '{{model.borderColor}}'
        'stroke-width': '{{model.borderWidth}}'
        'ng-mousedown': 'whenClick()'

      return parentGroup
    return {
      restrict: 'E',
      require: '^ngSvg',
      scope:
        model: '=',
        draggable: '=',
        whenClick: '&'

      link: ($scope, element, attr, ngSvgController)->

        ngSvg = ngSvgController;

        pathDefinition = createPathDefinition($scope, ngSvg)
        parentGroup = drawShape($scope, ngSvg)

        $compile(pathDefinition)($scope)
        $compile(parentGroup)($scope)
    }
