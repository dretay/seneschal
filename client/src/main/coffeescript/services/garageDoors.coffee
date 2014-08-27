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
              name: "Drew's Garage Door"
              zone: 7
              status: false
              floor: "mainFloor"
              type: "garageDoor"
              location:
                left: 75
                top: 81.5
              dimensions:
                width: "15%"
                height: "2%"
            }
            {
              name: "Trish's Garage Door"
              zone: 11
              status: false
              floor: "mainFloor"
              type: "garageDoor"
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
        outbound: "/exchange/garage.cmd"
        outboundTransform: (query, oldEntity)->
          operation: 'toggle_door'
          channel: if oldEntity.zone == 11 then 16 else 18
  ]
