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


      constructor: (config={})->
        {@get,@save,@delete,@update, @token} = config


      query: (query={}, isArray=true, action="get")->
        data = if isArray then [] else {}
        webStomp.getClient(@token).then (client)=>

          query = @[action].outboundTransform(query) if _.isFunction @[action].outboundTransform

          query = JSON.stringify query
          headers =
            'reply-to': "/temp-queue/#{@[action].inbound}"


          client.send "/amq/queue/#{@[action].outbound}",headers, query

          client.subscriptions["/temp-queue/#{@[action].inbound}"]= (response)=>
            rawData = JSON.parse response.body

            #apply any mapping that's necessary
            rawData = @[action].inboundTransform(rawData) if _.isFunction @[action].inboundTransform


            #map the raw data into a Response
            if _.isArray rawData
              final = _.map rawData, (element)=> new WebStompEntity(element,webStomp,@)
            else
              final = new WebStompEntity(rawData,webStomp,@)

            #replace the stub with the real response
            angular.copy(final, data)
            $rootScope.$apply()

        return data

      create: (data)->
        new WebStompEntity(data,webStomp,@)
    ]
