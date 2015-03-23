define [
    'angular'
    's/services'
    'r/WebStompResource'
  ],
(angular, services) ->
  'use strict'

  services.factory 'switches', ['webStompResource', (Resource)->
    new Resource
      get:
        outbound_rpc: "/exchange/wemo.cmd"
        subscription: "/exchange/wemo.status/fanout"
        outboundTransform: (rawData)->
          operation: 'list_switches'
        inboundTransform: (rawData, oldData)->
          if !_.isArray(rawData) and oldData?
            filteredLights = _.filter oldData, (light)->
              rawData.name == light.name
            for light in filteredLights
              light.status = if rawData.status == "0" then false else true

            #hum... something to look into... if you don't strip out all the messaging shit it explodes
            return _.map oldData, (record)->
              name: record.name
              status: record.status
              floor: record.floor
              type: record.type
              location:
                left: record.location.left
                top: record.location.top
                rotation: if record.location.rotation? then record.location.rotation else 0
          else

            lights = []

            for device in rawData
              if device.extra?
                unless _.isArray device.extra then device.extra = [device.extra]
                for extra in device.extra
                  lights.push
                    sensor_id: device.sensorindex
                    node_id: device.id
                    name: device.sketchname
                    status: !!device.real_value
                    floor: extra.floor
                    type: extra.type
                    location: extra.location



            return lights

      update:
        inbound: "wemo.lights"
        outbound: "/exchange/wemo.cmd"
        outboundTransform: (query={}, oldEntity)->
          if not _.isEmpty(query) then return query
          else
            unless oldEntity.status
              operation: 'toggle_on'
              switchName: oldEntity.name
            else
              operation: 'toggle_off'
              switchName: oldEntity.name
  ]