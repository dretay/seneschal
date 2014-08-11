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
                name: "Family Room Fan"
                status: false
                floor: "mainFloor"
                type: "fan"
                location:
                  left: 79
                  top: 32
              }
              {
                name: "Front Porch"
                status: false
                floor: "mainFloor"
                type: "light"
                location:
                  left: 30
                  top: 78
              }
              {
                name: "Front Porch"
                status: false
                floor: "mainFloor"
                type: "floodLight"
                location:
                  left: 72
                  top: 85
                  rotation: 43
              }
              {
                name: "Living Room"
                status: false
                floor: "mainFloor"
                type: "light"
                location:
                  left: 9
                  top: 57
              }
              {
                name: "Living Room"
                status: false
                floor: "mainFloor"
                type: "light"
                location:
                  left: 8
                  top: 82
              }
              {
                name: "Back Yard"
                status: false
                floor: "mainFloor"
                type: "floodLight"
                location:
                  left: 61
                  top: 5
                  rotation: 200
              }
              {
                name: "Family Room Lights"
                status: false
                floor: "mainFloor"
                type: "light"
                location:
                  left: 74
                  top: 32
              }
              {
                name: "Drews Office"
                status: false
                floor: "secondFloor"
                type: "monitor"
                location:
                  left: 15
                  top: 34
                dimensions:
                  width: "3em"
                  height: "3em"
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