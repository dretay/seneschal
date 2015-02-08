_ = require "underscore"
log = require "winston"
mysensors_db = require "./mysensors_db"
async = require 'async'
mysensors_constants = require './mysensors_constants'

appendedString = ""
writeQueue = async.queue (params, callback)->
    rfReceived params.appendedString.trim(), params.config, callback
, 1

encode = (destination, sensor, command, acknowledge, type, payload)->
  msg = "#{destination.toString(10)};#{sensor.toString(10)};#{command.toString(10)};#{acknowledge.toString(10)};#{type.toString(10)};"
  if command == 4
    for i in [0 .. payload.length]
      if payload[i] < 16 then msg += "0"
      msg += payload[i].toString(16)
  else
    msg += payload
  msg += '\n'
  return msg.toString()


saveProtocol = (sender, payload)-> mysensors_db.saveProtocol sender,payload

saveSensor = (sender, sensor, type)-> mysensors_db.saveSensor sender, sensor, type

# saveValue = (sender, sensor, type, payload, config)->
#   mysensors_db.saveValue sender, sensor, type, payload, (err,record)->
#     log.info "publishing updated sensor value"+ config.fanoutExchange
#     config.fanoutExchange.publish "#{type}", _.extend
#       sender: sender.toString()
#       sensor: sensor.toString()
#     ,payload

saveBatteryLevel = (sender, payload)-> mysensors_db.saveBatteryLevel sender, payload

saveSketchName = (sender, payload)-> mysensors_db.saveSketchName sender, payload

saveSketchVersion = (sender, payload)-> mysensors_db.saveSketchVersion sender, payload

sendTime = (destination, sensor, gw)->
  payload = (new Date().getTime()*.001)-18000
  command = mysensors_constants.C_INTERNAL
  acknowledge = 0 #no ack
  type = mysensors_constants.I_TIME
  td = encode destination, sensor, command, acknowledge, type, payload
  log.info "-> #{td.toString()}"
  gw.write td

sendNextAvailableSensorId = (gw,callback)->
  mysensors_db.sendNextAvailableSensorId (err, id)->
    if err?
      console.err "There was an error creating new sensor: #{err}"
      callback err
    else
      console.log("sending back id "+id);
      destination = mysensors_constants.BROADCAST_ADDRESS
      sensor = mysensors_constants.NODE_SENSOR_ID
      command = mysensors_constants.C_INTERNAL
      acknowledge = 0
      type = mysensors_constants.I_ID_RESPONSE
      payload = id
      td = encode destination, sensor, command, acknowledge, type, payload
      log.info "-> #{td.toString()}"
      gw.write td
      callback null


sendConfig = (destination, gw)->
  payload = "I"
  sensor = mysensors_constants.NODE_SENSOR_ID
  command = mysensors_constants.C_INTERNAL
  acknowledge = 0
  type = mysensors_constants.I_CONFIG
  td = encode destination, sensor, command, acknowledge, type, payload
  log.info "-> #{td.toString()}"
  gw.write td

saveRebootRequest = (destination)-> mysensors_db.saveRebootRequest destination, db

checkRebootRequest = (destination, db, gw)-> mysensors_db.checkRebootRequest destination, db, gw

sendRebootMessage = (destination, gw)->
  sensor = mysensors_constants.NODE_SENSOR_ID
  command = mysensors_constants.C_INTERNAL
  acknowledge = 0
  type = mysensors_constants.I_REBOOT
  payload = ""
  td = encode destination, sensor, command, acknowledge, type, payload
  log.info "-> #{td.toString()}"
  gw.write td


appendData = (str, config)->
    pos=0
    while str.charAt(pos) != '\n' and pos < str.length
        appendedString= "#{appendedString}#{str.charAt(pos)}"
        pos++

    if str.charAt(pos) == '\n'
        writeQueue.push
          appendedString: appendedString
          config: config
        , (err)->
          if err then log.error "Encountered error when processing gateway queue: #{err}"

        appendedString = ""

    if pos < str.length then appendData str.substr(pos+1,str.length-pos-1), config


rfReceived = (data, config, callback)->
  gw = config.gw
  if data != null and data != ""
    log.info '<- ' + data

    #decoding message
    [sender, sensor, command, ack, type, rawpayload] = _.map data.toString().split(";"), (datum,index)->
      if index == 5 then datum else +datum
    unless _.isString rawpayload then rawpayload = ""




    if command == mysensors_constants.C_STREAM
      log.info "Received serial message 'C_STREAM'"
      payload = []
      for i in [0..rawpayload.length] by 2
        payload.push(parseInt(rawpayload.substring(i, i + 2), 16))
    else
      payload = rawpayload

    switch command
      when mysensors_constants.C_PRESENTATION
        log.info "Received serial message 'C_PRESENTATION'"

        if sensor == mysensors_constants.NODE_SENSOR_ID
          mysensors_db.saveProtocol sender, payload, ->
            mysensors_db.saveSensor sender, sensor, type, callback
        else
          mysensors_db.saveSensor sender, sensor, type, callback

      when mysensors_constants.C_SET
        log.info "Received serial message 'C_SET'"
        if payload != null and payload != "null" and payload != ""
          mysensors_db.saveValue sender, sensor, type, payload, (err, record)->
            log.info "publishing updated value to /mysensors.status/C_SET:#{type}"
            config.statusExchange.publish "C_SET:#{type}", record
            callback null
        else
          log.info "payload is null, ignoring"
          callback null

      when mysensors_constants.C_REQ
        log.info "Received serial message 'C_REQ'"
        if payload?
          log.info "Request is for most recent stored value of #{payload}'s #{sensor}"
          mysensors_db.getNewestReadingBySensorindex parseInt(payload,10), sensor, (err, record)->
            payload = record.real_value
            command = mysensors_constants.C_REQ
            acknowledge = 0 #no ack
            type = mysensors_constants.I_CONFIG
            td = encode sender, sensor, command, acknowledge, type, payload
            log.info "-> #{td.toString()}"
            gw.write td
        callback null

      when mysensors_constants.C_INTERNAL
        switch type
          when mysensors_constants.I_BATTERY_LEVEL
            log.info "Received serial message 'I_BATTERY_LEVEL'"
            mysensors_db.saveBatteryLevel sender, payload, callback

          when mysensors_constants.I_TIME
            log.info "Received serial message 'I_TIME'"
            sendTime sender, sensor, gw
            callback null

          when mysensors_constants.I_VERSION
            log.info "Received serial message 'I_VERSION'"
            callback null

          when mysensors_constants.I_ID_REQUEST
            log.info "Received serial message 'I_ID_REQUEST'"
            sendNextAvailableSensorId gw, callback

          when mysensors_constants.I_ID_RESPONSE
            log.info "Received serial message 'I_ID_RESPONSE'"
            callback null

          when mysensors_constants.I_INCLUSION_MODE
            log.info "Received serial message 'I_INCLUSION_MODE'"
            callback null

          when mysensors_constants.I_CONFIG
            log.info "Received serial message 'I_CONFIG'"
            sendConfig sender, gw
            callback null

          when mysensors_constants.I_PING
            log.info "Received serial message 'I_PING'"
            callback null

          when mysensors_constants.I_PING_ACK
            log.info "Received serial message 'I_PING_ACK'"
            callback null

          when mysensors_constants.I_LOG_MESSAGE
            log.info "Received serial message 'I_LOG_MESSAGE'"
            callback null

          when mysensors_constants.I_CHILDREN
            log.info "Received serial message 'I_CHILDREN'"
            callback null

          when mysensors_constants.I_SKETCH_NAME
            log.info "Received serial message 'I_SKETCH_NAME'"
            mysensors_db.saveSketchName sender, payload, callback

          when mysensors_constants.I_SKETCH_VERSION
            log.info "Received serial message 'I_SKETCH_VERSION'"
            mysensors_db.saveSketchVersion sender, payload, callback

          when mysensors_constants.I_REBOOT
            log.info "Received serial message 'I_REBOOT'"
            callback null

      when mysensors_constants.C_STREAM
        log.info "Received serial message 'C_STREAM'"
        callback null
      else
        log.info "Unable to process message with command index #{command}"


connectToGateway = (config, callback)->

  parser = new require('inireader').IniReader()
  parser.load('../config/site.ini')

  SerialPort = require('serialport').SerialPort
  gwPort = parser.param 'mysensors.gwPort'
  gwBaud = parser.param 'mysensors.gwBaud'
  gw = new SerialPort gwPort, baudrate: gwBaud
  config = _.extend config, gw: gw
  gw.open (err)->
    if err then callback err
    else
      log.info "connected to serial gateway at #{gwPort}"
      callback null, config
      gw.on 'data', (rd)-> appendData rd.toString(), config
      .on 'end', -> log.info('disconnected from gateway')
      .on 'error', -> log.error 'connection error'


exports.connectToGateway = connectToGateway
exports.encode = encode

