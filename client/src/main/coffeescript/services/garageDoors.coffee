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
        inbound: "garage.cmd"
        outbound: "/exchange/garage.cmd"
        subscription: "/exchange/garage.status/fanout"
        outboundTransform: (rawData)->
          operation: 'dump_door_timers'
        inboundTransform: (rawData, oldData)->
          doors = [
            {
              name: "Left Door"
              zone: 7
              status: false
              floor: "mainFloor"
              location:
                left: 75
                top: 81.5
              dimensions:
                width: "15%"
                height: "2%"
            }
            {
              name: "Right Door"
              zone: 11
              status: false
              floor: "mainFloor"
              location:
                left: 53
                top: 81.5
              dimensions:
                width: "15%"
                height: "2%"
            }
          ]
          for door in doors
            door.timestamp = moment(rawData[door.zone].timestamp*1000).add('minutes', moment().zone())
            door.open = rawData[door.zone].state

          return doors
      update:
        outbound: "/exchange/garagedoor.cmd"
        outboundTransform: (rawData, args)->
          rawData.name
  ]
