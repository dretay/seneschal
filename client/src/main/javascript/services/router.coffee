define [
    'angular'
    's/services'
    'underscore'
    'r/WebStompResource'

  ],
(angular, services, _) ->
  'use strict'

  services.factory 'router', ['webStompResource', (Resource)->
    new Resource
      get:
        subscription: "/exchange/actiontec.status/fanout"
        outbound_rpc: "/exchange/actiontec.cmd"
        outboundTransform: ->
          operation: "list_mac_addresses"
        inboundTransform: (data)->
          _.map data, (ele)->
            ele

  ]