define [
    'jquery'
    'underscore'
    'util/_deep'
  ],
($, _)->
  class WebStompEntity
    constructor: (data, messageBus, scope)->

      for key, value of data
        @[key] = value

      #close over the scope and bus so they don't look like response properties
      @getScope = ->
        scope
      @getMessageBus = ->
        messageBus

    send: (args, opts)->
      @getScope().query args, opts

    save: (args)->
      @send(args, {oldEntity:@, action: "save", isArray: false})
    delete: (args)->
      @send(args, {oldEntity:@, action: "delete", isArray: false})
    update: (args)->
      @send(args, {oldEntity:@, action: "update", isArray: false})