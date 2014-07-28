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
            filteredLights = _.filter oldData, (light)->rawData.name == light.name
            # light = _.findWhere oldData,{name: rawData.name}
            for light in filteredLights
              # light.status = Boolean(result.status)
              light.status = if rawData.status == "on" then true else false
            return oldData
          else
            #todo: this needs to be in something like redis or the service... i shouldn't be storing it...
            lights = [
              {
                name: "Family Room Fan"
                status: false
                floor: "mainFloor"
                type: "fan"
                location:
                  left: 69
                  top: 31
              }
              {
                name: "Front Porch"
                status: false
                floor: "mainFloor"
                type: "light"
                location:
                  left: 37
                  top: 75
              }
              {
                name: "Front Porch"
                status: false
                floor: "mainFloor"
                type: "light"
                location:
                  left: 64
                  top: 82
              }
              {
                name: "Living Room"
                status: false
                floor: "mainFloor"
                type: "light"
                location:
                  left: 27
                  top: 53
              }
              {
                name: "Living Room"
                status: false
                floor: "mainFloor"
                type: "light"
                location:
                  left: 23
                  top: 79
              }
              {
                name: "Back Yard"
                status: false
                floor: "mainFloor"
                type: "light"
                location:
                  left: 58
                  top: 4
              }
              {
                name: "Family Room Lights"
                status: false
                floor: "mainFloor"
                type: "light"
                location:
                  left: 64
                  top: 31
              }
              {
                name: "Drews Office"
                status: false
                floor: "secondFloor"
                type: "light"
                location:
                  left: 29
                  top: 43
              }
              {
                name: "Master Bedroom"
                status: false
                floor: "secondFloor"
                type: "light"
                location:
                  left: 60
                  top: 24
              }
            ]

            for result in rawData
              filteredLights = _.filter lights, (light)->result.name == light.name
              for light in filteredLights
                light.status = Boolean(result.status)

            return lights

      update:
        inbound: "wemo.lights"
        outbound: "/exchange/lights.cmd"
        outboundTransform: (rawData, args)->
          unless rawData.status
            operation: 'toggle_on'
            switchName: rawData.name
          else
            operation: 'toggle_off'
            switchName: rawData.name
  ]