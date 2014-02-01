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
                left: 46
                top: 17
            }
            {
              name: "Front Porch"
              status: false
              floor: "mainFloor"
              location:
                left: 31
                top: 80
            }
            {
              name: "Family Room"
              status: false
              floor: "mainFloor"
              location:
                left: 65
                top: 23
            }
            {
              name: "Back Yard"
              status: false
              floor: "mainFloor"
              location:
                left: 50
                top: 1
            }
            {
              name: "Living Room"
              status: false
              floor: "mainFloor"
              location:
                left: 15
                top: 80
            }
            {
              name: "Drews Office"
              status: false
              floor: "secondFloor"
              location:
                left: 11
                top: 43
            }
            {
              name: "Master Bedroom"
              status: false
              floor: "secondFloor"
              location:
                left: 80
                top: 13
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