define [
  'angular'
  's/services'
  'moment'
  'r/WebStompResource'
],
(angular, services, moment) ->
  'use strict'

  services.factory 'garageDoors', ['webStompResource', (Resource)->
    new Resource
      get:
        subscription: "/exchange/garagedoor.status/fanout"
        inboundTransform: (rawData, oldData)->
          zones = [
            {
              name: "right"
              floor: "mainFloor"
              status: _.findWhere(rawData, {"door":"left"}).status
              location:
                left: 52
                top: 80.5
              dimensions:
                width: 11.5
                height: 1.5
            }
            {
              name: "left"
              floor: "mainFloor"
              status: _.findWhere(rawData, {"door":"right"}).status
              location:
                left: 67
                top: 80.5
              dimensions:
                width: 11.5
                height: 1.5
            }
          ]


          return zones
      update:
        outbound: "/exchange/garagedoor.cmd"
        outboundTransform: (rawData, args)->
          rawData.name
  ]