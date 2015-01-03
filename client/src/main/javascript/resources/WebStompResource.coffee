define [
    'angular'
    'underscore'
    './WebStompEntity'
    'jquery'
    'r/resources'
    'uuid'
    'p/webStomp'

  ],
(angular, _, WebStompEntity, $, resources, uuid) ->
  'use strict'
  resources.factory 'webStompResource', ['$rootScope', 'webStomp', '$log', ($rootScope, webStomp, $log)->
    class WebStompResource

      constructor: (config = {})->
        { @get,@save,@delete,@update,@subscribe} = config

      query: (query = {}, opts={})->

        #process args
        isArray = if _.isUndefined opts.isArray then true else opts.isArray
        action = if _.isUndefined opts.action then "get"  else opts.action
        scope = if _.isUndefined opts.scope then null else opts.scope
        oldEntity = if _.isUndefined opts.oldEntity then null else opts.oldEntity
        subscription = if _.isUndefined opts.subscription then null else opts.subscription
        client = null
        rpc_uuid = null

        deferred = $.Deferred()
        data = if isArray then [] else {}
        handleResponse = (response)=>
          #delete the temporary queue once the reply is received
          if client.subscriptions["/temp-queue/#{rpc_uuid}"]?
            $log.debug "WebStompResource::handleResponse RPC message received from request on #{@[action].outbound_rpc}; deleting temporary queue #{rpc_uuid}"
            delete client.subscriptions["/temp-queue/#{rpc_uuid}"]
          else
            $log.debug "WebStompResource::handleResponse Received message on #{response.headers['destination']}: #{response.headers['content-length']} chars of #{response.headers['content-type']}"


          if response?
            @lastUpdate = new Date().getTime()
            rawData = JSON.parse response.body

            #apply any mapping that's necessary
            rawData = @[action].inboundTransform(rawData, data, client) if _.isFunction @[action].inboundTransform

            #map the raw data into a Response
            if _.isArray rawData
              final = _.map rawData, (element)=>
                new WebStompEntity(element, webStomp, @)
            else if rawData?
              final = new WebStompEntity(rawData, webStomp, @)
            else
              final = null

            #make really really sure this isn't something weird
            if action == "get" and final != null and !_.isEmpty(final) and (_.isArray(final) == _.isArray(data))
              #replace the stub with the real response
              angular.copy(final, data)
            else
              deferred.resolve(final)

            if scope? then scope.$apply() else $rootScope.$apply()


        webStomp.getClient().then (webStompClient)=>
          client = webStompClient

          #perform outbound transform of data if desired
          query = @[action].outboundTransform(query, oldEntity) if _.isFunction @[action].outboundTransform

          #if the query is already stringified don't do anything
          #if its not stringified then stringify it
          if _.isString query or _.isNumber query
            query = query
          else
            query = unless _.isEmpty query then JSON.stringify query

          #setup temporary queue and handler if we're expecting an rpc reply
          if @[action].outbound_rpc?
            rpc_uuid = uuid.v4()
            headers =
              'reply-to': "/temp-queue/#{rpc_uuid}"
            client.subscriptions["/temp-queue/#{rpc_uuid}"] = handleResponse

          #determine if we're sending to queues created outside the STOMP gateway
          outbound = if @[action].outbound? then @[action].outbound else @[action].outbound_rpc
          if outbound and query?
            if outbound.indexOf("/") == -1
              client.send "/amq/queue/#{outbound}", headers, query
            else
              client.send "#{outbound}", headers, query

          #if a scope and subscription are defined then subscribe
          if @[action].subscription? and not subscription?
            if _.isNull(scope)
              $log.error("WebStompResource::query Subscription #{@[action].subscription} defined without scope - subscriptions will not be cleaned up!")
            unless _.isArray @[action].subscription then @[action].subscription = [@[action].subscription]
            for subscription in @[action].subscription
              webStomp.subscribe(subscription, handleResponse, scope)


        #if we're 'getting' return a placeholder that can be copied over, else return a deferred
        if action == "get" then return data else return deferred.promise()

      create: (data)->
        new WebStompEntity(data, webStomp, @)
  ]
