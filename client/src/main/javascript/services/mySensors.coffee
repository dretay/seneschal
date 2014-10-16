define [
    'angular'
    's/services'
    'moment'
    'underscore'
    'r/WebStompResource'
  ],
(angular, services, moment, _) ->
  'use strict'

  services.factory 'mySensors', ['webStompResource', (Resource)->
    new Resource
      get:
        subscription: "/exchange/mysensors.status/fanout"
        outbound_rpc: "/exchange/mysensors.cmd"
        outboundTransform: (rawData)->
          cmd: "dumpSensorData"
#          cmd: "querySensor"
#          node: 1
#          start: 1412035388
        inboundTransform: (readings, oldData)->

          #subscription update
          if not _.isArray readings
            oldReading = _.findWhere(oldData, {id:readings.node})
            oldSensor = _.findWhere(oldReading.data, {sensorindex:readings.sensorindex})
            oldSensor.real_value = readings.real_value

            return oldData
          else
            mysensors= [
              {
                floor: "secondFloor"
                name: "Computer Room"
                data:{}
                location:
                  left: 15
                  top: 78
                  padding_top: "0.5em"
              }
              {
                floor: "secondFloor"
                name: "Drew's Office"
                data:{}
                location:
                  left: 13
                  top: 42
                  padding_top: "0.5em"
              }
              {
                floor: "secondFloor"
                name: "Master Bedroom"
                data:{}
                location:
                  left: 59
                  top: 18
                  padding_top: "0.5em"
              }
              {
                floor: "mainFloor"
                name: "Living Room"
                data:{}
                location:
                  left: 16
                  top: 56
                  padding_top: "0.5em"
              }
              {
                floor: "mainFloor"
                name: "Family Room"
                data:{}
                location:
                  left: 82
                  top: 28
                  padding_top: "0.5em"
              }
              {
                floor: "basement"
                name: "Gym"
                data:{}
                location:
                  left: 61
                  top: 25
                  padding_top: "0.5em"
              }
              {
                floor: "basement"
                name: "Theatre"
                data:{}
                location:
                  left: 38
                  top: 64
                  padding_top: "0.5em"
              }
              {
                floor: "basement"
                name: "Guest Bedroom"
                data:{}
                location:
                  left: 15
                  top: 30
                  padding_top: "0.5em"
              }
            ]

            for sensor in mysensors
              for reading in readings
                if reading.sketchname.toLowerCase() == sensor.name.toLowerCase()
                  sensor.id = reading.id
                  sensor.data[reading.shortname] =
                    real_value: reading.real_value
                    created: reading.created
                    sensorindex: reading.sensorindex
            return mysensors

  ]