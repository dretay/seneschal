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
                id: 1
                floor: "secondFloor"
                name: "Unused Bedroom"
                data:{}
                location:
                  left: 15
                  top: 78
                  padding_top: "0.5em"
              }
            ]

            for sensor in mysensors
              for reading in readings
                if reading.id == sensor.id
                  sensor.data[reading.shortname] =
                    real_value: reading.real_value
                    created: reading.created
                    sensorindex: reading.sensorindex
            return mysensors

  ]