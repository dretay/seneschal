define [
    'angular'
    's/services'
    'moment'
    'underscore'
    'r/WebStompResource'
  ],
(angular, services, moment, _) ->
  'use strict'

  services.factory 'nest', ['webStompResource', (Resource)->
    new Resource
      get:
        subscription: "/exchange/thermostat.status/fanout"
        outbound_rpc: "/exchange/thermostat.cmd"
        outboundTransform: (rawData)->
          cmd: "snapshot"
        inboundTransform: (rawData, oldData)->

          #todo: this needs to be in something like redis or the service... i shouldn't be storing it...
          devices =
            thermostats: [
              {
                name: "home"
                floor: "mainFloor"
                location:
                  left: 28
                  top: 32
              }
            ]
            smoke_co_alarms: [
              {
                name: "Upstairs"
                floor: "secondFloor"
                location:
                  left: 36
                  top: 35
              }
              {
                name: "Basement"
                floor: "basement"
                location:
                  left: 36
                  top: 35
              }
              {
                name: "Entryway"
                floor: "mainFloor"
                location:
                  left: 36
                  top: 35
              }
            ]


          for thermostat in devices.thermostats
            thermostat.data = _.findWhere rawData.devices.thermostats, {name: thermostat.name}
            thermostat.away = _.first(_.pluck(rawData.structures, "away"))
          for smoke_co_alarm in devices.smoke_co_alarms
            smoke_co_alarm.data = _.findWhere rawData.devices.smoke_co_alarms, {name: smoke_co_alarm.name}


          return devices



      update:
        outbound: "/exchange/nest.cmd"
        outboundTransform: (rawData, args)->
          cmd: 'changeTemp'
          targetTemperature: rawData.targetTemperature
          device_id: rawData.device_id


  ]