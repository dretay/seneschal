async = require 'async'
rabbitmq = require "./rabbitmq"
engine = require "./engine"
log = require "winston"


async.waterfall [
  rabbitmq.connectToBroker
  engine.compileRules
  ],(err,config)->
  if err then log.error err else log.info "server startup complete"
