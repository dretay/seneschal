define [
    'angular'
    's/services'
    'moment'
    'underscore'
    'chroma'
    'r/WebStompResource'
  ],
(angular, services, moment, _, chroma) ->
  'use strict'

  services.factory 'mySensorsNode', ['webStompResource', (Resource)->
    new Resource
      get:
        outbound_rpc: "/exchange/mysensors.cmd"
        outboundTransform: (rawData)->
          cmd: "getBinnedReadings"
          binUnit: rawData.binUnit
          nodes: rawData.nodes
          timeFrame:
            start: moment(rawData.startDate).format()
            end: moment(rawData.endDate).format()

        inboundTransform: (rawData, oldData)->
          readings = []
          for reading in rawData
            series = _.findWhere readings, {key: "#{reading.sketchname} - #{reading.longname}"}
            if not _.isObject series
              series =
                key: "#{reading.sketchname} - #{reading.longname}"
                values: []
              readings.push series
            series.values.push [moment(reading.bin).valueOf(), reading.avg]

          return readings

  ]