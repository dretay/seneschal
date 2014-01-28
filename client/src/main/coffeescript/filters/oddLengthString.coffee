define [
  'f/filters'
],
(filters) ->
  'use strict'

  filters.filter 'oddLengthString', [-> (string) ->
    if string.length % 2 !=0
      string += " "
    return string.replace(/\s/g, "\u00A0")
  ]