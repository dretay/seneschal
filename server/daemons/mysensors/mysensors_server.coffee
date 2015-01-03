async = require 'async'
serial_gateway = require "./serial_gateway"
rabbitmq = require "./rabbitmq"
log = require "winston"

async.waterfall [
  rabbitmq.connectToBroker
  serial_gateway.connectToGateway
  ],(err,config)->
    if err then log.error err else log.info "server startup complete"
