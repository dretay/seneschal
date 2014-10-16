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
        outbound_rpc: "/exchange/lights.cmd"
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
              }
              {
                name: "Family Room Fan"
                status: false
                floor: "mainFloor"
                type: "fan"
                location:
                  left: 74
                  top: 28
              }
              {
                name: "Front Porch"
                status: false
                floor: "mainFloor"
                type: "light"
                location:
                  left: 30
                  top: 77
              }
              {
                name: "Front Porch"
                status: false
                floor: "mainFloor"
                type: "floodLight"
                location:
                  left: 69
                  top: 84
                  rotation: 43
              }
              {
                name: "Living Room"
                status: false
                floor: "mainFloor"
                type: "light"
                location:
                  left: 7
                  top: 55
              }
              {
                name: "Living Room"
                status: false
                floor: "mainFloor"
                type: "light"
                location:
                  left: 7
                  top: 85
              }
              {
                name: "Back Yard"
                status: false
                floor: "mainFloor"
                type: "floodLight"
                location:
                  left: 61
                  top: 1
                  rotation: 200
              }
              {
                name: "Family Room Lights"
                status: false
                floor: "mainFloor"
                type: "light"
                location:
                  left: 68
                  top: 28
              }
              {
                name: "Drews Office"
                status: false
                floor: "secondFloor"
                type: "monitor"
                location:
                  left: 14
                  top: 30
              }
              {
                name: "Master Bedroom"
                status: false
                floor: "secondFloor"
                type: "light"
                location:
                  left: 86
                  top: 8
              }
              {
                name: "Master Bedroom"
                status: false
                floor: "secondFloor"
                type: "light"
                location:
                  left: 86
                  top: 30
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
        outbound_rpc: "/exchange/lights.cmd"
        outboundTransform: (query, oldEntity)->
          unless oldEntity.status
            operation: 'toggle_on'
            switchName: oldEntity.name
          else
            operation: 'toggle_off'
            switchName: oldEntity.name
  ]