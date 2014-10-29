async = require 'async'
rabbitmq = require "./rabbitmq"
engine = require "./engine"
log = require "winston"


async.waterfall [
  rabbitmq.connectToBroker
  rabbitmq.setupBindings
  rabbitmq.setupCommandQueue
  engine.executeActiveRules
  ],(err,config)->
  if err then log.error err else log.info "server startup complete"
