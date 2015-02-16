define [
    'angular'
    's/services'
  ],
(angular, services, moment) ->
  'use strict'

  services.factory 'controlsOffCanvas', ['cnOffCanvas', (cnOffCanvas)->
    cnOffCanvas
      controller: ($scope)->
        $scope.name = "loser"
      template: '<div class="off-canvas__nav">Hello {{name}}</div>'
  ]