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
  resources.factory 'webStompResource', ['$rootScope', 'webStomp', ($rootScope, webStomp)->
    class WebStompResource


      constructor: (config = {})->
        {@get, @save, @delete, @update, @token} = config

      query: (query = {}, isArray = true, action = "get")->
        deferred = $.Deferred()
        data = if isArray then [] else {}

        webStomp.getClient().then (client)=>
          handleResponse = (response)=>
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

              if action == "get" and final != null and !_.isEmpty(final) and (_.isArray(final) == _.isArray(data))
                #replace the stub with the real response
                angular.copy(final, data)
              else
                deferred.resolve(final)

              $rootScope.$apply()

          query = @[action].outboundTransform(query) if _.isFunction @[action].outboundTransform
          if _.isString query or _.isNumber query
            query = query
          else
            query = unless _.isEmpty query then JSON.stringify query else null
          if @[action].inbound?
            console.log "expecting a reply"
            headers =
              'reply-to': "/temp-queue/#{@[action].inbound}"

          if @[action].outbound and query?
            if @[action].outbound.indexOf("/") == -1
              client.send "/amq/queue/#{@[action].outbound}", headers, query
            else
              client.send "#{@[action].outbound}", headers, query
          if @[action].subscription? then @subscriptionHandler = client.subscribe @[action].subscription, handleResponse
          if @[action].inbound? then client.subscriptions["/temp-queue/#{@[action].inbound}"] = handleResponse


        if action == "get" then return data else return deferred.promise()

      create: (data)->
        new WebStompEntity(data, webStomp, @)
    ]
