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
    $get: ($log, $http)->
      unless _.isString @hostname then @hostname = 'localhost'
      unless _.isNumber @port then @port = 443
      unless _.isString @username then @username = 'guest'
      unless _.isString @password then @password = 'guest'

      subscriptions= []
      connectionAttempts = 0
      client = null
      connectionStatus = 0
      ws = null
      getSocket = =>
        $log.debug "getting connection... "
        ws = new SockJS "https://#{@hostname}:#{@port}/rabbitmq/stomp",
          devel:true
          debug:true
        client = Stomp.over(ws)
        if @logger? then client.debug = @logger

#        client.heartbeat.outgoing = 1
#        client.heartbeat.incoming = 1
        return client
      getRabbitCredentials = ()=>
        $http
          method: "GET"
          url: "https://#{@hostname}:#{@port}/getRabbitCredentials"
          withCredentials: true
          responseType: "json"

#          type: 'GET'
#          url: "https://#{@hostname}:#{@port}/getRabbitCredentials"
#          dataType: 'json'
#          xhrFields:
#            withCredentials: true


      client: null

      subscribe: (topic, handler, scope, resubscription)->
        @getClient().then (client)=>
          subscription = client.subscribe topic, handler

          unless resubscription then subscriptions.push
            topic: topic
            handler: handler
            scope: scope
          $log.debug "WebStomp::subscribe Subscribing to #{topic} (#{subscription.id})"

          if scope? and not resubscription
            scope.$on '$destroy', =>
              $log.info "WebStomp::subscribe Unsubscribing to #{topic} (#{subscription.id})"
              client.unsubscribe subscription.id


      getClient: (deferred, reconnect)->
        if client == null || reconnect then @client = client = getSocket() else @client = client
        if reconnect then connectionStatus = 0

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
            if error == "Whoops! Lost connection to undefined"
              $log.error  "WebStomp::getClient Lost connection to broker, attempting to reconnect"
              deferred = $.Deferred()
              @getClient(deferred, true)
              deferred.then (client)=>
                for subscription in subscriptions
                  @subscribe subscription.topic, subscription.handler, subscription.scope, true


            else
              $log.error  "RABBITMQ STOMP ERROR HANDLER CALLED!!!!!!!!!!!!!! #{JSON.stringify arguments}"
              deferred.reject client
          connectionStatus = 1
          getRabbitCredentials().success((data, status, headers, config)->
            connectionStatus = 2
            username = data.username
            password = data.password
            client.connect(username, password, on_connect, on_error, '/')
          ).error((data, status, headers, config)->
            $log.debug  "WebStomp::getClient can't get client credentials, aborting all connection attempts"
            deferred.reject()
            connectionStatus = -1
          )
        isResolved = =>
          if connectionStatus == 3 and deferred.state() != "resolved"
            $log.debug  "WebStomp::getClient returning established connection"
            deferred.resolve client
          else if deferred.state() == "pending" and connectionStatus > 0
            connectionAttempts +=1
            $log.debug  "WebStomp::getClient connection not ready on attempt #{connectionAttempts}"
#            if connectionAttempts > 60 then location.reload()
            @getClient deferred


        setTimeout isResolved, 500


        return deferred.promise()


