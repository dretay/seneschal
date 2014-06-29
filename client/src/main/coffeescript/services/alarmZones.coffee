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
        subscription: "/exchange/eyezon.alarm/fanout"
        outbound: "eyezon.alarm"
        inbound: "eyezon.alarm"
        outboundTransform: -> "^02,$"
        inboundTransform: (rawData, oldData)->
          #if the partition changes to ready
          if rawData.name == "Partition State Change"
            partition = _.find rawData.payload.partitions, (partition)->partition.partition == 0

            if partition.status == "Ready" and oldData? then _.map oldData, (zone)-> zone.open = false

            return oldData

          else if rawData.name == "Zone Timer Dump"
            #todo: this needs to be in something like redis or the service... i shouldn't be storing it...
            zones = [
              {
                name: "Front Door"
                zone: 0
                status: false
                floor: "mainFloor"
                location:
                  left: 38
                  top: 73
                dimensions:
                  width: 3.5
                  height: 1.5
              }
              {
                name: "Interior Garage Door"
                zone: 1
                status: false
                floor: "mainFloor"
                location:
                  left: 49.2
                  top: 42
                dimensions:
                  width: 1
                  height: 5.5
                labelStyle:
                  "padding-top": "0.75%"
              }
              {
                name: "Family Room Door"
                zone: 3
                status: false
                floor: "mainFloor"
                location:
                  left: 50.5
                  top: 9.8
                dimensions:
                  width: 7
                  height: 2
              }
              {
                name: "Basement Door"
                zone: 4
                status: false
                floor: "basement"
                location:
                  left: 38
                  top: 10
                dimensions:
                  width: 5
                  height: 2
              }
            ]

            for zone in zones
              serverData = _.find rawData.payload.timers, (entry)-> entry.zone == zone.zone
              zone.timestamp = moment(serverData.timestamp)
              zone.open = if serverData.delta >= 10 and oldData? then false else true


            return zones

          return null
  ]