define [
    'd/directives'
    'jquery'
    'underscore'
    's/alarmZones'
  ],
(directives, $, _) ->
  'use strict'

  directives.directive 'alarmZoneStatus', ->
    restrict: 'E'
    replace: false
    template: "<span>{{zonesStatusMsg()}}</span>"

    controller: ($scope, $log, alarmZones)->
      $scope.alarmZones = alarmZones.query(null,{scope:$scope})

      $scope.zonesStatusMsg = ->
        for zone in $scope.alarmZones
          return "#{zone.name} Open" if zone.open
        return "All Doors Closed"