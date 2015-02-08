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
            mysensors= {}

            for reading in readings
              # conflate multiple sensor readings into a single node entry
              unless mysensors[reading.sketchname]?
                mysensors[reading.sketchname] =
                  name: reading.sketchname
                  data: {}

              if reading.extra?
                mysensors[reading.sketchname].floor = reading.extra.floor
                mysensors[reading.sketchname].location = reading.extra.location

              mysensors[reading.sketchname].data[reading.shortname]=
                real_value: reading.real_value
                created: reading.created
                sensorindex: reading.sensorindex
            _.values mysensors


  ]