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
        outbound_rpc: "/exchange/wemo.cmd"
        subscription: "/exchange/wemo.status/fanout"
        outboundTransform: (rawData)->
          operation: 'list_switches'
        inboundTransform: (rawData, oldData)->
          if !_.isArray(rawData) and oldData?
            filteredLights = _.filter oldData, (light)->
              rawData.name == light.name
            for light in filteredLights
              light.status = if rawData.status == "0" then false else true

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
                name: "Christmas Tree"
                status: false
                floor: "mainFloor"
                type: "christmastree"
                location:
                  left: 22
                  top: 80
              }
              {
                name: "Family Room Fan"
                status: false
                floor: "mainFloor"
                type: "fan"
                location:
                  left: 74
                  top: 30
              }
              {
                name: "Front Porch"
                status: false
                floor: "mainFloor"
                type: "light"
                location:
                  left: 29
                  top: 78
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
                  left: 62
                  top: 2
                  rotation: 200
              }
              {
                name: "Family Room Lights"
                status: false
                floor: "mainFloor"
                type: "light"
                location:
                  left: 68
                  top: 30
              }
              {
                name: "3d Printer"
                status: false
                floor: "secondFloor"
                type: "threedprinter"
                location:
                  left: 21
                  top: 32
              }
              {
                name: "Drews Office"
                status: false
                floor: "secondFloor"
                type: "light"
                location:
                  left: 7
                  top: 41.5
              }
              {
                name: "Trishs Office"
                status: false
                floor: "secondFloor"
                type: "light"
                location:
                  left: 60
                  top: 59
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
              switchInstances = _.where(lights, {name: result.name})
              unless _.isArray switchInstances then switchInstances = [switchInstances]
              for switchInstance in switchInstances
                switchInstance.status = result.status


            return lights

      update:
        inbound: "wemo.lights"
        outbound: "/exchange/wemo.cmd"
        outboundTransform: (query, oldEntity)->
          unless oldEntity.status
            operation: 'toggle_on'
            switchName: oldEntity.name
          else
            operation: 'toggle_off'
            switchName: oldEntity.name
  ]