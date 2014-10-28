define [
    'angular'
    's/services'
    'moment'
    'r/WebStompResource'
  ],
(angular, services, moment) ->
  'use strict'

  services.factory 'alarmKeypad', ['webStompResource', (Resource)->
    new Resource
      get:
        subscription: "/exchange/eyezon.status/fanout"
        outbound_rpc: "/exchange/eyezon.cmd"
        outboundTransform: ->
          "getKeypadStatus"
        inboundTransform: (rawData, oldData)->
          if rawData.name == "Virtual Keypad Update"
            return {
              name: "Alarm Keypad"
              floor: "mainFloor"
              type: "keypad"
              data: rawData.payload
            }

          return null
  ]