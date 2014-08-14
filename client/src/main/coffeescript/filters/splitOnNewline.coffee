define [
    'f/filters'
    'underscore'
  ],
(filters, _) ->
  'use strict'

  filters.filter 'splitOnNewline', [->
    (line) ->
      if _.isString line then line.split("\n") else ""
  ]