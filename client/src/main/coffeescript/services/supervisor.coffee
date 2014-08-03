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
        outbound: "/exchange/system.cmd"
        inbound: "supervisor.cmd"
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
        outbound: "/exchange/system.cmd"
        outboundTransform: (rawData, args)->
          operation: rawData.operation
          processname: rawData.entity.name


  ]