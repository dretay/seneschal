define [
  'angular'
  's/services'
  'r/WebStompResource'
],
(angular, services) ->
  'use strict'

  services.factory 'lights', ['webStompResource', (Resource)->
    new Resource
      get:
        inbound: "wemo.lights"
        outbound: "wemo.lights"
        outboundTransform: (rawData)->
          operation: 'list_switches'
        inboundTransform: (rawData)->
          #todo: this needs to be in something like redis or the service... i shouldn't be storing it...
          lights = [
            {
              name: "Guest Bedroom"
              status: false
              floor: "basement"
              location:
                left: 18
                top: 24
            }
            {
              name: "Front Porch"
              status: false
              floor: "mainFloor"
              location:
                left: 33
                top: 81
            }
            {
              name: "Family Room"
              status: false
              floor: "mainFloor"
              location:
                left: 69
                top: 22
            }
            {
              name: "Back Yard"
              status: false
              floor: "mainFloor"
              location:
                left: 50
                top: 0
            }
            {
              name: "Living Room"
              status: false
              floor: "mainFloor"
              location:
                left: 18
                top: 81
            }
            {
              name: "Drews Office"
              status: false
              floor: "secondFloor"
              location:
                left: 17
                top: 43
            }
            {
              name: "Master Bedroom"
              status: false
              floor: "secondFloor"
              location:
                left: 83
                top: 12
            }
          ]

          for result in rawData
            light = _.find lights, (light)->result.name == light.name
            light.status = Boolean(result.status)

          return lights

      update:
        inbound: "wemo.lights"
        outbound: "wemo.lights"
        outboundTransform: (rawData, args)->
          if rawData.status
            operation: 'toggle_on'
            switchName: rawData.name
          else
            operation: 'toggle_off'
            switchName: rawData.name
  ]