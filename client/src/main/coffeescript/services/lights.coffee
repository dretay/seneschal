define [
  'angular'
  's/services'
  'r/WebStompResource'
],
(angular, services) ->
  'use strict'

  services.factory 'lights', ['webStompResource', (Resource)->
    new Resource
      get:
        inbound: "wemo.lights"
        outbound: "wemo.lights"
        outboundTransform: (rawData)->
          operation: 'list_switches'
        inboundTransform: (rawData)->
          _.map rawData, (light)->
            name: light.name
            status: Boolean(light.status)

      update:
        inbound: "wemo.lights"
        outbound: "wemo.lights"
        outboundTransform: (rawData, args)->
          if rawData.status
            operation: 'toggle_on'
            switchName: rawData.name
          else
            operation: 'toggle_off'
            switchName: rawData.name
  ]