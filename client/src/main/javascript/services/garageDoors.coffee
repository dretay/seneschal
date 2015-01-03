define [
    'angular'
    's/services'
    'moment'
    'util/MySensorsTypes'
    'r/WebStompResource'
  ],
(angular, services, moment, MySensorsTypes) ->
  'use strict'

  services.factory 'garageDoors', ['webStompResource', (Resource)->
    new Resource
      get:
        subscription: [
          "/exchange/mysensors.status/#{MySensorsTypes.V_LOCK_STATUS}"
        ]
        outbound_rpc: "/exchange/mysensors.cmd"
        outboundTransform: (rawData)->
          cmd: "getCurrentReadings"
          types: [MySensorsTypes.S_DOOR]
        inboundTransform: (rawData, oldData)->
          #subscription update
          if not _.isArray rawData
            sensor = _.findWhere(oldData, {nodeindex: rawData.node, sensorindex: rawData.sensorindex})
            sensor.open = (rawData.real_value == 1)

            return oldData
          else
            doors = [
              {
                name: "Drew's Garage Door"
                sensorindex: 1
                status: false
                floor: "mainFloor"
                type: "doorZone"
                location:
                  left: 75
                  top: 84
                dimensions:
                  width: "15%"
                  height: "2%"
              }
              {
                name: "Trish's Garage Door"
                sensorindex: 2
                status: false
                floor: "mainFloor"
                type: "doorZone"
                location:
                  left: 53
                  top: 84
                dimensions:
                  width: "15%"
                  height: "2%"
              }
            ]
            for door in doors
              data = _.findWhere rawData, sensorindex:door.sensorindex
              door.timestamp = moment(data.created)
              door.open = data.real_value == 1
              door.nodeindex = data.id

            return doors
      update:
        outbound_rpc: "/exchange/mysensors.cmd"
        outboundTransform: (params,record)->
          cmd: 'toggleSensor'
          node_id: record.nodeindex
          sensor_id: record.sensorindex
          message_type: MySensorsTypes.C_SET
          sub_type: MySensorsTypes.V_LOCK_STATUS
          payload: ""

  ]
