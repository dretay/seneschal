define [
  'f/filters'
  'underscore'
],
(filters) ->
  'use strict'

  filters.filter 'celsiusToDegrees', [-> (string) ->

    if _.isNumber string
      return Math.floor(Number(string) * (9/5) + 32)
    return string

  ]