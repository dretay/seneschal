define [
    'f/filters'
    'moment'
  ],
  (filters) ->
    'use strict'

    filters.filter 'prettyTypeName', [->
      (key) ->
        switch key
          when 'light' then "Light Bulb"
          when 'floodLight' then "Flood Light"
          when 'christmastree' then "Christmas Tree"
          when 'fan' then "Fan"
          when 'dehumidifier' then "Dehumidifier"
          when 'monitor' then "Computer Monitor"
          when 'keypad' then "Keypad"
          when 'doorZone' then "Door Zone"
    ]