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
        subscription: "/exchange/eyezon.status/fanout"
        outbound_rpc: "/exchange/eyezon.cmd"
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
                  left: 33
                  top: 63
                dimensions:
                  width: "5em"
                  height: "0.5em"
              }
              {
                name: "Interior Garage Door"
                zone: 1
                status: false
                floor: "mainFloor"
                type: "doorZone"
                location:
                  left: 47
                  top: 31
                dimensions:
                  width: "0.5em"
                  height: "3.5em"
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
                  left: 48.5
                  top: 7.2
                dimensions:
                  width: "5em"
                  height: "0.5em"
              }
              {
                name: "Basement Door"
                zone: 4
                status: false
                floor: "basement"
                type: "doorZone"
                location:
                  left: 34
                  top: 4.7
                dimensions:
                  width: "6em"
                  height: "0.5em"
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