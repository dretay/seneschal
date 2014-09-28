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
#        subscription: "/exchange/mysensors.status/fanout"
        outbound_rpc: "/exchange/mysensors.cmd"
        outboundTransform: (rawData)->
          cmd: "snapshot"
        inboundTransform: (rawData, oldData)->
          sensorTypes = [
            "S_DOOR", "S_MOTION", "S_SMOKE",
            "S_LIGHT", "S_DIMMER", "S_COVER",
            "S_TEMP", "S_HUM", "S_BARO",
            "S_WIND", "S_RAIN", "S_UV",
            "S_WEIGHT", "S_POWER", "S_HEATER",
            "S_DISTANCE", "S_LIGHT_LEVEL", "S_ARDUINO_NODE",
            "S_ARDUINO_RELAY", "S_LOCK", "S_IR",
            "S_WATER", "S_AIR_QUALITY", "S_CUSTOM",
            "S_DUST", "S_SCENE_CONTROLLER	"]
          mysensors= [
            {
              id: 1
              floor: "secondFloor"
              location:
                left: 20
                top: 75
            }
          ]

          for sensor in mysensors
            sensor.data =  _.reduceRight rawData[sensor.id], (result,datum,sensor)->
                result[sensorTypes[sensor]] =
                  timestamp: datum.timestamp
                  value: datum.value
                return result
              ,{}
          return mysensors

  ]