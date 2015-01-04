define [
    'angular'
    's/services'
    'moment'
    'underscore'
    'util/MySensorsTypes'
    'r/WebStompResource'

  ],
(angular, services, moment, _, MySensorsTypes) ->
  'use strict'


  services.factory 'tempAndHum', ['webStompResource', (Resource)->
    new Resource
      update:
        update:
          outbound: "/exchange/mysensors.cmd"
          outboundTransform: (rawData)->
            cmd: "toggleSensor"
      get:
        subscription: [
          "/exchange/mysensors.status/C_SET:#{MySensorsTypes.V_TEMP}",
          "/exchange/mysensors.status/C_SET:#{MySensorsTypes.V_HUM}"
        ]
        outbound_rpc: "/exchange/mysensors.cmd"
        outboundTransform: (rawData)->
          cmd: "getCurrentReadings"
          types: [MySensorsTypes.S_TEMP, MySensorsTypes.S_HUM]
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
                name: "Garage Door"
                data:{}
                location:
                  left: 71
                  top: 46
                  padding_top: "0.5em"
              }
              {
                floor: "mainFloor"
                name: "Family Room"
                data:{}
                location:
                  left: 82
                  top: 30
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
                  top: 67
                  padding_top: "0.5em"
              }
              {
                floor: "basement"
                name: "Guest Bedroom"
                data:{}
                location:
                  left: 15
                  top: 27
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