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
              name: "Basement"
              status: false
              floor: "basement"
              location:
                left: 27
                top: 9
            }
            {
              name: "Front Porch"
              status: false
              floor: "mainFloor"
              location:
                left: 19
                top: 48
            }
            {
              name: "Family Room"
              status: false
              floor: "mainFloor"
              location:
                left: 47
                top: 9
            }
            {
              name: "Back Yard"
              status: false
              floor: "mainFloor"
              location:
                left: 28
                top: 0
            }
            {
              name: "Living Room"
              status: false
              floor: "mainFloor"
              location:
                left: 8
                top: 48
            }
            {
              name: "Drews Office"
              status: false
              floor: "secondFloor"
              location:
                left: 8
                top: 26
            }
            {
              name: "Master Bedroom"
              status: false
              floor: "secondFloor"
              location:
                left: 48
                top: 8
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