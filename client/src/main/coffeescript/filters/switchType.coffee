define [
    'f/filters'
  ],
(filters) ->
  'use strict'

  filters.filter 'switchType', [-> (items, type) ->
    _.filter items, (item)-> if item.type == type then true else false
  ]