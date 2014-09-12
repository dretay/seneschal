define [
    'f/filters'
    'underscore'
  ],
(filters) ->
  'use strict'

  filters.filter 'doubleEncodeURIComponent', [->
    (string) ->
      return string

  ]