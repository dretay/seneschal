define [
    'f/filters'
    'moment'
  ],
  (filters) ->
    'use strict'

    filters.filter 'humanizedDuration', [->
      (date) ->
        moment.duration( moment(date) - moment()).humanize(true)
    ]