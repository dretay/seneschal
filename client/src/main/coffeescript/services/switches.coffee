define [
    'angular'
    's/services'
    'r/WebStompResource'
  ],
(angular, services) ->
  'use strict'

  services.factory 'switches', ['webStompResource', (Resource)->
    new Resource
      get:
        inbound: "wemo.lights"
        outbound: "/exchange/lights.cmd"
        subscription: "/exchange/lights.status/fanout"
        outboundTransform: (rawData)->
          operation: 'list_switches'
        inboundTransform: (rawData, oldData)->
          if !_.isArray(rawData) and oldData?
            filteredLights = _.filter oldData, (light)->
              rawData.name == light.name
            for light in filteredLights
              light.status = if rawData.status == "on" then true else false

            #hum... something to look into... if you don't strip out all the messaging shit it explodes
            return _.map oldData, (record)->
              name: record.name
              status: record.status
              floor: record.floor
              type: record.type
              location:
                left: record.location.left
                top: record.location.top
                rotation: if record.location.rotation? then record.location.rotation else 0
          else
            #todo: this needs to be in something like redis or the service... i shouldn't be storing it...
            outerClassMaps =
              light: ($scope)->
                "fa fa-spinner fa-spin fa-3x": -> $scope.pending
                "lightbulb-on": -> $scope.appliance.status == true
                "lightbulb-off": -> $scope.appliance.status == false
              flood: ($scope)->
                "fa fa-spinner fa-spin fa-3x": -> $scope.pending
                "floodLight-on": -> $scope.appliance.status == true
                "floodLight-off": -> $scope.appliance.status == false
              fan: ($scope)->
                "fa fa-spinner fa-spin fa-3x": -> $scope.pending
                "fan fa fa-spin": -> $scope.appliance.status == true
                "fan": -> $scope.appliance.status == false
              dehumidifier: ($scope)->
                "fa fa-spinner fa-spin fa-3x": -> $scope.pending
                "dehumidifier-on": -> $scope.appliance.status == true
                "dehumidifier-off": -> $scope.appliance.status == false
              monitor: ($scope)->
                "fa fa-spinner fa-spin fa-3x monitor-pending": -> $scope.pending
                "monitor-on": -> $scope.appliance.status == true
                "monitor-off": -> $scope.appliance.status == false
            lights = [
              {
                name: "Basement Dehumidifier"
                status: false
                floor: "basement"
                type: "dehumidifier"
                location:
                  left: 47
                  top: 11
                  rotation: 90
                getOuterClassMap: outerClassMaps['dehumidifier']
              }
              {
                name: "Family Room Fan"
                status: false
                floor: "mainFloor"
                type: "fan"
                location:
                  left: 77
                  top: 28
                getOuterClassMap: outerClassMaps['fan']
              }
              {
                name: "Front Porch"
                status: false
                floor: "mainFloor"
                type: "light"
                location:
                  left: 29.5
                  top: 77
                getOuterClassMap: outerClassMaps['light']
              }
              {
                name: "Front Porch"
                status: false
                floor: "mainFloor"
                type: "floodLight"
                location:
                  left: 70
                  top: 84
                  rotation: 43
                getOuterClassMap: outerClassMaps['flood']
              }
              {
                name: "Living Room"
                status: false
                floor: "mainFloor"
                type: "light"
                location:
                  left: 7
                  top: 54
                getOuterClassMap: outerClassMaps['light']
              }
              {
                name: "Living Room"
                status: false
                floor: "mainFloor"
                type: "light"
                location:
                  left: 6
                  top: 83
                getOuterClassMap: outerClassMaps['light']

              }
              {
                name: "Back Yard"
                status: false
                floor: "mainFloor"
                type: "floodLight"
                location:
                  left: 61
                  top: 2
                  rotation: 200
                getOuterClassMap: outerClassMaps['flood']

              }
              {
                name: "Family Room Lights"
                status: false
                floor: "mainFloor"
                type: "light"
                location:
                  left: 72
                  top: 28
                getOuterClassMap: outerClassMaps['light']
              }
              {
                name: "Drews Office"
                status: false
                floor: "secondFloor"
                type: "monitor"
                location:
                  left: 14
                  top: 30
                getOuterClassMap: outerClassMaps['monitor']
#                dimensions:
#                  width: "3em"
#                  height: "3em"
              }
              {
                name: "Master Bedroom"
                status: false
                floor: "secondFloor"
                type: "light"
                location:
                  left: 86
                  top: 8
                getOuterClassMap: outerClassMaps['light']
              }
              {
                name: "Master Bedroom"
                status: false
                floor: "secondFloor"
                type: "light"
                location:
                  left: 86
                  top: 30
                getOuterClassMap: outerClassMaps['light']
              }
            ]

            for result in rawData
              filteredLights = _.filter lights, (light)->
                result.name == light.name
              for light in filteredLights
                light.status = Boolean(result.status)

            return lights

      update:
        inbound: "wemo.lights"
        outbound: "/exchange/lights.cmd"
        outboundTransform: (query, oldEntity)->
          unless oldEntity.status
            operation: 'toggle_on'
            switchName: oldEntity.name
          else
            operation: 'toggle_off'
            switchName: oldEntity.name
  ]