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
      unless _.isNumber @port then @port = 443
      unless _.isString @username then @username = 'guest'
      unless _.isString @password then @password = 'guest'


      client = null
      connectionStatus = 0
      getSocket = =>
        console.log "getting connection... "
        ws = new SockJS("https://#{@hostname}:#{@port}/rabbitmq/stomp")
        client = Stomp.over(ws)
        if @logger? then client.debug = @logger

        client.heartbeat.outgoing = 0
        client.heartbeat.incoming = 0
        return client
      getRabbitCredentials = (token)=>
        $.ajax
          type: 'GET'
          url: "https://#{@hostname}:#{@port}/getRabbitCredentials"
          dataType: 'json'
          data:
            token: token

      client: null
      subscriptions: []
      setToken: (token)->
        @token = token
      getClient: (token, deferred)->
        token = if @token? then @token else token
        if client == null then @client = client = getSocket() else @client = client
        unless deferred? then deferred = $.Deferred()
        username = null
        password = null

        #if we're requesting a connection for the first time and one's already been established
        # if connectionStatus == 3
        #  deferred.resolve client
        #  return

        if connectionStatus == 0
          console.log "starting connection..."
          on_connect = =>
            console.log "connection ready... resolving within connect callback"
            connectionStatus = 3
            @subscriptions = client.subscriptions
            if deferred.state() != "resolved" then deferred.resolve client
          on_error = =>
            console.log "RABBITMQ STOMP ERROR HANDLER CALLED!!!!!!!!!!!!!! #{JSON.stringify arguments}"
            deferred.reject client
          connectionStatus = 1
          getRabbitCredentials(token).then (data)->
            connectionStatus = 2
            username = data.username
            password = data.password
            client.connect(username, password, on_connect, on_error, '/')

        isResolved = =>
          if connectionStatus == 3 and deferred.state() != "resolved"
            console.log "connection ready... resolving within watcher"
            deferred.resolve client
          else if deferred.state() == "pending"
            console.log "connection not ready yet... trying again"
            @getClient token, deferred


        setTimeout isResolved, 500


        return deferred.promise()


