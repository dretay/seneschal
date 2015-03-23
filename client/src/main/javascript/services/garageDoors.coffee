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
            sensor = _.findWhere(oldData, {node_id: rawData.node, sensor_id: rawData.sensorindex})
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
                    sensor_id: device.sensorindex
                    floor: extra.floor
                    type: extra.type
                    location: extra.location
                    dimensions: extra.dimensions
                    timestamp: moment(device.created)
                    open: !!device.real_value
                    node_id: device.id
            return doors
      update:
        outbound_rpc: "/exchange/mysensors.cmd"
        outboundTransform: (query={},record)->
          if not _.isEmpty(query) then return query
          else
            cmd: 'toggleSensor'
            node_id: record.node_id
            sensor_id: record.sensor_id
            message_type: MySensorsTypes.C_SET
            sub_type: MySensorsTypes.V_LOCK_STATUS
            payload: ""

  ]
