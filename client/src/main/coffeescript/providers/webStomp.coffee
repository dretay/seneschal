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


      deferred = $.Deferred()
      pollingStarted = false
      pollingCycles = 0
      subscriptions: []
      getSocket: =>
        ws = new SockJS("https://#{@hostname}:#{@port}/rabbitmq/stomp")
        client = Stomp.over(ws)
        # client.debug = -> null

        client.heartbeat.outgoing = 0
        client.heartbeat.incoming = 0
        return client

      getClient: (token)=>
        `var instanceScope = this`
        client = instanceScope.getSocket()
        username = null
        password = null
        connectionStatus = 0
        console.log "getting connection... "
        on_connect = ->
          console.log "connected to broker, resolving... "
          connectionStatus = 3
          @subscriptions = client.subscriptions
          deferred.resolve client
        on_error = ->
          console.log "RABBITMQ STOMP ERROR HANDLER CALLED!!!!!!!!!!!!!! #{JSON.stringify arguments}"
          deferred.reject client

        console.log "starting connection..."
        connectionStatus = 1
        $.ajax
          type: 'GET'
          url: "https://#{@hostname}:#{@port}/getRabbitCredentials"
          dataType: 'json'
          data:
            token: token
          success: (data)->
            connectionStatus = 2
            username = data.username
            password = data.password
            client.connect(username, password, on_connect, on_error, '/')
          error: (jqXHR, textStatus, errorThrown )->
            console.err textStatus

        unless pollingStarted
          isResolved = ->
            if connectionStatus == 3
              console.log "connection ready... should have been resolved"
              # deferred.resolve client
            else if connectionStatus == 2 && pollingCycles > 10
              pollingCycles = 0
              _.bind(->
                console.log "credentials retrieved but socket not initialized, trying again"
                this.getClient token
              , instanceScope)
            else
              pollingCycles +=1
              console.log "connection not ready(#{connectionStatus})... waiting some more"
              setTimeout isResolved, 500
          pollingStarted = true
          setTimeout isResolved, 500
        else
          console.log "not setting up new poller - one is already registered"

        return deferred.promise()


