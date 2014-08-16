define [
    'angular'
    'underscore'
    './WebStompEntity'
    'jquery'
    'r/resources'
    'p/webStomp'

  ],
(angular, _, WebStompEntity, $, resources) ->
  'use strict'
  resources.factory 'webStompResource', ['$rootScope', 'webStomp', '$log', ($rootScope, webStomp, $log)->
    class WebStompResource

      constructor: (config = {})-> { @get, @save, @delete, @update, @subscribe } = config

      query: (query = {}, opts={})->

        #process args
        isArray = if _.isUndefined opts.isArray then true else opts.isArray
        action = if _.isUndefined opts.action then "get"  else opts.action
        scope = if _.isUndefined opts.scope then null else opts.scope
        oldEntity = if _.isUndefined opts.oldEntity then null else opts.oldEntity
        subscription = if _.isUndefined opts.subscription then null else opts.subscription
        client = null

        deferred = $.Deferred()
        data = if isArray then [] else {}
        handleResponse = (response)=>
          $log.debug "WebStompResource::handleResponse Received message on #{@[action].inbound}: #{response.headers['content-length']} chars of #{response.headers['content-type']}"
          #delete the temporary queue once the reply is received
          if client.subscriptions["/temp-queue/#{@[action].inbound}"]?
            $log.debug "WebStompResource::handleResponse RPC message received; deleting temporary queue #{@[action].inbound}"
            delete client.subscriptions["/temp-queue/#{@[action].inbound}"]

          if response?
            @lastUpdate = new Date().getTime()
            rawData = JSON.parse response.body

            #apply any mapping that's necessary
            rawData = @[action].inboundTransform(rawData, data, client) if _.isFunction @[action].inboundTransform

            #map the raw data into a Response
            if _.isArray rawData
              final = _.map rawData, (element)=>
                new WebStompEntity(element, webStomp, @)
            else
              final = new WebStompEntity(rawData, webStomp, @)

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
          #TODO:  this delete itself when a message comes in
          if @[action].inbound?
            headers =
              'reply-to': "/temp-queue/#{@[action].inbound}"
            client.subscriptions["/temp-queue/#{@[action].inbound}"] = handleResponse

          #determine if we're sending to queues created outside the STOMP gateway
          if @[action].outbound and query?
            if @[action].outbound.indexOf("/") == -1
              client.send "/amq/queue/#{@[action].outbound}", headers, query
            else
              client.send "#{@[action].outbound}", headers, query

          #if a scope and subscription are defined then subscribe
          if @[action].subscription? and not subscription?
            if _.isNull(scope)
              $log.error("WebStompResource::query Subscription #{@[action].subscription} defined without scope - subscriptions will not be cleaned up!")
            subscription = client.subscribe @[action].subscription, handleResponse
            $log.debug "WebStompResource::query Subscribing to #{@[action].subscription} (#{subscription.id})"
            if scope?
              scope.$on '$destroy', =>
                $log.info "WebStompResource::query Unsubscribing to #{@[action].subscription} (#{subscription.id})"
                client.unsubscribe subscription.id




        #if we're 'getting' return a placeholder that can be copied over, else return a deferred
        if action == "get" then return data else return deferred.promise()

      create: (data)->
        new WebStompEntity(data, webStomp, @)
  ]
