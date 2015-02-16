define [
    'f/filters'
    'moment'
  ],
  (filters) ->
    'use strict'

    filters.filter 'prettyFloorName', [->
      (key) ->
        switch key
          when "basement" then "Basement"
          when "mainFloor" then "Main Floor"
          when "secondFloor" then "Second Floor"
    ]