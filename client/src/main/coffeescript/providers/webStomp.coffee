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
    $get: ($log)->
      unless _.isString @hostname then @hostname = 'localhost'
      unless _.isNumber @port then @port = 443
      unless _.isString @username then @username = 'guest'
      unless _.isString @password then @password = 'guest'

      connectionAttempts = 0
      client = null
      connectionStatus = 0
      getSocket = =>
        $log.debug "getting connection... "
        ws = new SockJS("https://#{@hostname}:#{@port}/rabbitmq/stomp",null,{devel:true,debug:true})
        client = Stomp.over(ws)
        if @logger? then client.debug = @logger

#        client.heartbeat.outgoing = 1
#        client.heartbeat.incoming = 1
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


        if connectionStatus == 0
          $log.debug  "WebStomp::getClient starting connection"
          on_connect = =>
            $log.info  "WebStomp::getClient connection ready over #{@client.ws.protocol}"
            connectionStatus = 3
            @subscriptions = client.subscriptions
            if deferred.state() != "resolved" then deferred.resolve client
          on_error = (error)=>
#            if error == "Whoops! Lost connection to undefined"
#              location.reload()

            $log.error  "RABBITMQ STOMP ERROR HANDLER CALLED!!!!!!!!!!!!!! #{JSON.stringify arguments}"
            deferred.reject client
          connectionStatus = 1
          getRabbitCredentials(token).then (data)->
            connectionStatus = 2
            username = data.username
            password = data.password
            client.connect(username, password, on_connect, on_error, '/')

        isResolved = =>
          if connectionStatus == 3 and deferred.state() != "resolved"
            $log.debug  "WebStomp::getClient returning established connection"
            deferred.resolve client
          else if deferred.state() == "pending"
            connectionAttempts +=1
            $log.debug  "WebStomp::getClient connection not ready on attempt #{connectionAttempts}"
            if connectionAttempts > 20 then location.reload()
            @getClient token, deferred


        setTimeout isResolved, 500


        return deferred.promise()


