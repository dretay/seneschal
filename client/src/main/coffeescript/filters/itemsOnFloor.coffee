define [
    'f/filters'
  ],
(filters) ->
  'use strict'

  filters.filter 'itemsOnFloor', [->
    (items, floor) ->
      _.filter items, (item)-> if item.floor == floor then true else false
  ]