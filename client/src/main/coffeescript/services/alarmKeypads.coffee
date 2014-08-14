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
        outboundTransform: ->
          "getKeypadStatus"
        inboundTransform: (rawData, oldData)->
          if rawData.name == "Virtual Keypad Update"
            #todo: this needs to be in something like redis or the service... i shouldn't be storing it...
            keypads = [
              {
                name: "Garage Entryway"
                floor: "mainFloor"
                location:
                  left: 45
                  top: 40.5
                dimensions:
                  width: "3em"
                  height: "3em"
              }
              {
                name: "Second Floor Hallway"
                floor: "secondFloor"
                location:
                  left: 42
                  top: 31
                  rotation: -31
                dimensions:
                  width: "2em"
                  height: "2em"
              }

            ]


            for keypad in keypads
              keypad.data = rawData.payload

            return keypads

          return null
  ]