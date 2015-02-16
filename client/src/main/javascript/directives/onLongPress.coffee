define [
    'd/directives'
    'jquery'
    'underscore'
  ],
(directives, $, _) ->
  'use strict'

  # from https://gist.githubusercontent.com/BobNisco/9885852/raw/2a89f980f59af08c1f2d727ff3979dd93463f440/directive.js
  directives.directive 'onLongPress', ($timeout)->

    restrict: 'A',
    link: ($scope, $elm, $attrs)->
      $elm.bind 'mousedown', (evt)->
        if evt.which == 1
          #Locally scoped variable that will keep track of the long press
          $scope.longPress = true

          #We'll set a timeout for 600 ms for a long press
          $timeout ->
            if $scope.longPress
              #If the touchend event hasn't fired,
              #apply the function given in on the element's on-long-press attribute
              $scope.$apply -> $scope.$eval $attrs.onLongPress
          , 600


      $elm.bind 'mouseup', (evt)->
        if evt.which == 1
          #Prevent the onLongPress event from firing
          $scope.longPress = false
          #If there is an on-touch-end function attached to this element, apply it
          if $attrs.onTouchEnd
            $scope.$apply -> $scope.$eval $attrs.onTouchEnd
