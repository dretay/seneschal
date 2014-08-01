define [
  'angular'
  's/services'
  'moment'
  'r/WebStompResource'
],
(angular, services, moment) ->
  'use strict'

  services.factory 'alarmKeypads', ['webStompResource', (Resource)->
    new Resource
      get:
        subscription: "/exchange/alarm.status/fanout"
        outbound: "/exchange/alarm.cmd"
        inbound: "eyezon.alarm"
        outboundTransform:->
          "getKeypadStatus"
        inboundTransform: (rawData, oldData)->
          if rawData.name == "Virtual Keypad Update"
            #todo: this needs to be in something like redis or the service... i shouldn't be storing it...
            keypads = [
              {
                name: "Garage Entryway"
                floor: "mainFloor"
                location:
                  left: 89
                  top: 84
              }
              {
                name: "Second Floor Hallway"
                floor: "secondFloor"
                location:
                  left: 49
                  top: 32
              }

            ]


            for keypad in keypads
              keypad.data = rawData.payload

            return keypads

          return null
  ]