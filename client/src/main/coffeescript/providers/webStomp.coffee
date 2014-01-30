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


      connected = false

      getClient: (token)=>
        on_connect = ->
          connected = true
          deferred.resolve client
        on_error = ->
          deferred.reject client

        deferred = $.Deferred()

        unless connected
          $.ajax
            type: 'GET'
            url: "https://#{@hostname}:#{@port}/getRabbitCredentials"
            dataType: 'json'
            data:
              token: token
            success: (data)->
              client.connect(data.username, data.password, on_connect, on_error, '/')
        else
          #clean up any stale connections from other pages
          for subscription, listener of client.subscriptions
            client.unsubscribe subscription
          deferred.resolve client

        return deferred.promise()




