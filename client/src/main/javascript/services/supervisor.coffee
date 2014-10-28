define [
    'angular'
    's/services'
    'underscore'
    'r/WebStompResource'
  ],
(angular, services, _) ->
  'use strict'

  services.factory 'supervisor', ['webStompResource', (Resource)->
    new Resource
      get:
        subscription: "/exchange/supervisor.status/fanout"
        outbound_rpc: "/exchange/system.cmd"
        outboundTransform: (command)->
          if _.isObject(command) and !_.isEmpty(command)
            return command
          else
            return {operation: "list_processes"}

        inboundTransform: (rawData, oldData)->
          if _.isArray rawData
            return rawData
          else if _.isString rawData
            return {contents: rawData}


      update:
        inbound: "supervisor.cmd"
        outbound_rpc: "/exchange/system.cmd"
        outboundTransform: (rawData, entity)->
          operation: rawData.operation
          processname: entity.name


  ]