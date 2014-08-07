define [
    'angular'
    's/services'
    'underscore'
    'r/WebStompResource'
  ],
(angular, services, _) ->
  'use strict'

  services.factory 'router', ['webStompResource', (Resource)->
    new Resource
      get:
        subscription: "/exchange/router.status/fanout"

  ]