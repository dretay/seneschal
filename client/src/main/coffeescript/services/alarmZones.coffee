define [
    'angular'
    's/services'
    'moment'
    'r/WebStompResource'
  ],
(angular, services, moment) ->
  'use strict'

  services.factory 'alarmZones', ['webStompResource', (Resource)->
    new Resource
      get:
        subscription: "/exchange/alarm.status/fanout"
        outbound_rpc: "/exchange/alarm.cmd"
        outboundTransform: ->
          "^02,$"
        inboundTransform: (rawData, oldData)->
          #if the partition changes to ready
          if rawData.name == "Partition State Change"
            partition = _.find rawData.payload.partitions, (partition)->
              partition.partition == 0

            if partition.status == "Ready" and oldData? then _.map oldData, (zone)->
              zone.open = false

            return oldData

          else if rawData.name == "Zone Timer Dump"
            #todo: this needs to be in something like redis or the service... i shouldn't be storing it...
            zones = [
              {
                name: "Front Door"
                zone: 0
                status: false
                floor: "mainFloor"
                type: "doorZone"
                location:
                  left: 35
                  top: 74
                dimensions:
                  width: "4.5%"
                  height: "1.5%"
              }
              {
                name: "Interior Garage Door"
                zone: 1
                status: false
                floor: "mainFloor"
                type: "doorZone"
                location:
                  left: 49
                  top: 41
                dimensions:
                  width: "1%"
                  height: "6.5%"
                labelStyle:
                  "padding-top": "0.75%"
              }
              {
                name: "Family Room Door"
                zone: 3
                status: false
                floor: "mainFloor"
                type: "doorZone"
                location:
                  left: 52.5
                  top: 8.1
                dimensions:
                  width: "11%"
                  height: "2%"
              }
              {
                name: "Basement Door"
                zone: 4
                status: false
                floor: "basement"
                type: "doorZone"
                location:
                  left: 37
                  top: 8.5
                dimensions:
                  width: "6%"
                  height: "2%"
              }
            ]

            for zone in zones
              serverData = _.find rawData.payload.timers, (entry)->
                entry.zone == zone.zone
              zone.timestamp = moment(serverData.timestamp)
              zone.open = if serverData.delta >= 10 and oldData? then false else true


            return zones

          return null
  ]