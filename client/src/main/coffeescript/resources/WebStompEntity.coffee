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

    send: (action, args = {})->
      args['entity'] = @
      @getScope().query args, false, action

    save: (args = @)->
      @send('save', args)
    delete: (args = @)->
      @send('delete', args)
    update: (args = @)->
      @send('update', args)