#defined as a provider so that it can be configured prior to injection
define [
  'p/providers'
  'stomp'
  'sockjs'
  'jquery'
  'underscore'
],
(providers, Stomp, SockJS, $)->
  'use strict'
  providers.provider 'webStomp', ->
    $get: ->
      unless _.isString @hostname then @hostname = 'localhost'
      unless _.isNumber @port then @port = 9000
      unless _.isString @username then @username = 'guest'
      unless _.isString @password then @password = 'guest'

      ws = new SockJS("https://#{@hostname}:#{@port}/rabbitmq/stomp")
      client = Stomp.over(ws)
      # client.debug = -> null

      client.heartbeat.outgoing = 0
      client.heartbeat.incoming = 0


      connectionStatus = 0

      subscriptions: []
      getClient: (token, retry)=>
        console.log "getting connection... "+(if(_.isBoolean(retry) && retry) then 'again...' else '')
        on_connect = ->
          connectionStatus = 2
          @subscriptions = client.subscriptions
          deferred.resolve client
        on_error = ->
          deferred.reject client

        deferred = $.Deferred()

        unless connectionStatus == 2
          console.log "starting connection..."
          connectionStatus = 1
          $.ajax
            type: 'GET'
            url: "https://#{@hostname}:#{@port}/getRabbitCredentials"
            dataType: 'json'
            data:
              token: token
            success: (data)->
              client.connect(data.username, data.password, on_connect, on_error, '/')
          setTimeout (=> unless connectionStatus == 2 then getClient token, true) ,300
        else if connectionStatus == 2
          deferred.resolve client
        else
          console.log "connection not ready... waiting"
          isResolved = ->
            if connectionStatus == 2
              console.log "connection ready... resolving"
              deferred.resolve client
            else
              console.log "connection still not ready... waiting some more"
              setTimeout isResolved, 200
          setTimeout isResolved, 200

        return deferred.promise()


