define [
  'f/filters'
],
(filters) ->
  'use strict'

  filters.filter 'degreesToCelsius', [-> (string) ->

    if _.isNumber string
      return (Number(string) - 32) * 5/9
    return string
  ]