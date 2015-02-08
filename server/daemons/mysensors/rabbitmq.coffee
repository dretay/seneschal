_ = require "underscore"
amqp = require 'amqp'
mysensors_db = require "./mysensors_db"
log = require "winston"
serial_gateway = require "./serial_gateway"

#connect to the amqp broker
connectToBroker = (callback)->
  parser = new require('inireader').IniReader()
  parser.load('../config/site.ini')
  rabbitmqUsername = parser.param 'rabbitmq.username'
  rabbitmqPassword = parser.param 'rabbitmq.password'
  rabbitmqHost = parser.param 'rabbitmq.host'
  connection = amqp.createConnection url: "amqp://#{rabbitmqUsername}:#{rabbitmqPassword}@#{rabbitmqHost}:5672"
  connection.addListener 'error', (exception)->
    log.error "AMQP connection error: #{exception.message}"
  connection.addListener 'ready', ->
    log.info "successfully connected to amqp broker"
    setupSubscriptions amqpConnection: connection, callback



setupSubscriptions = (config, callback)->
  config.amqpConnection.exchange "mysensors.status", {type: "topic", durable: true, autoDelete: false}, (statusExchange)->
    config.amqpConnection.queue 'mysensors.cmd', (q)->
      config.amqpConnection.exchange "mysensors.cmd", {type: "direct", durable: true, autoDelete: false}, (directExchange)->
          q.bind directExchange, '', ->
            q.subscribe (message, headers, deliveryInfo, messageObject)->
              message = JSON.parse message.data.toString()
              if message.cmd? then log.info "Received AMQP command: #{message.cmd}"
              if message.cmd == "getAllSensors"
                mysensors_db.getAllSensors (err, sensors)->
                  config.amqpConnection.publish deliveryInfo.replyTo,sensors

              else if message.cmd == "getCurrentReadings"
                log.info "Querying current sensor readings for types #{message.types}"
                mysensors_db.getNewestReadings message.types, (err, readings)->
                  config.amqpConnection.publish deliveryInfo.replyTo,readings

              else if message.cmd == "getBinnedReadings"
                mysensors_db.getBinnedReadings message.nodes, message.binUnit, message.timeFrame, (err, readings)->
                  config.amqpConnection.publish deliveryInfo.replyTo,readings

              else if message.cmd == "toggleSensor"
                {node_id,sensor_id,message_type, sub_type, payload} = message
                ack = 1;
                td = serial_gateway.encode node_id, sensor_id, message_type, ack, sub_type, payload
                log.info "-> #{td.toString()}"
                config.gw.write td
                #TODO: send out broadcast update
              else
                log.warn "command '#{message.cmd}' not supported"

            log.info "completed binding and subscribing to broker"
            callback null, _.extend config, statusExchange: statusExchange

exports.connectToBroker = connectToBroker
