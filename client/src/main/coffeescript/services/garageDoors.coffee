define [
  'angular'
  's/services'
  'moment'
  'r/WebStompResource'
],
(angular, services, moment) ->
  'use strict'

  services.factory 'garageDoors', ['webStompResource', (Resource)->
    new Resource
      get:
        inbound: "raspi.cmd"
        outbound: "/exchange/garagedoor.cmd"
        subscription: "/exchange/garagedoor.status/fanout"
        outboundTransform: (rawData)->
          operation: 'list_doors'
        inboundTransform: (rawData, oldData)->
          zones = [
            {
              name: "right"
              floor: "mainFloor"
              status: if rawData.rightDoor == 1 then "closed" else "open"
              location:
                left: 52
                top: 80.5
              dimensions:
                width: 11.5
                height: 1.5
            }
            {
              name: "left"
              floor: "mainFloor"
              status: if rawData.leftDoor == 1 then "closed" else "open"
              location:
                left: 67
                top: 80.5
              dimensions:
                width: 11.5
                height: 1.5
            }
          ]


          return zones
      update:
        outbound: "/exchange/garagedoor.cmd"
        outboundTransform: (rawData, args)->
          rawData.name
  ]
