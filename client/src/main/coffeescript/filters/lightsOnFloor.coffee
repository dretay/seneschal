define [
  'f/filters'
],
(filters) ->
  'use strict'

  filters.filter 'lightsOnFloor', [-> (lights, floor) ->
    _.filter lights, (light)-> if light.floor == floor then true else false
  ]