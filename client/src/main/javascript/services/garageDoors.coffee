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
          "/exchange/mysensors.status/C_SET:#{MySensorsTypes.V_LOCK_STATUS}"
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
            doors = []
            for device in rawData
              if device.extra?
                unless _.isArray device.extra then device.extra = [device.extra]
                for extra in device.extra
                  doors.push
                    name: device.sketchname
                    sensorindex: device.sensorindex
                    floor: extra.floor
                    type: extra.type
                    location: extra.location
                    dimensions: extra.dimensions
                    timestamp: moment(device.created)
                    open: !!device.real_value
                    nodeindex: device.id
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
