define [
    'f/filters'
    'moment'
  ],
(filters) ->
  'use strict'

  filters.filter 'plaintextAge', [->
    (timestamp) ->
      moment.duration(timestamp*-1, "seconds").humanize(true)
  ]