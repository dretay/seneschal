define [
    'f/filters'
    'moment'
  ],
(filters) ->
  'use strict'

  filters.filter 'timestampAge', [->
    (timestamp) ->
      moment.duration(moment.unix(timestamp) - moment()).humanize(true)
  ]