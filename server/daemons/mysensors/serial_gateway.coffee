_ = require "underscore"
log = require "winston"
mysensors_db = require "./mysensors_db"
async = require 'async'

fwSketches                  = [ ]
fwDefaultType               = 0xFFFF #index of hex file from array above (0xFFFF
FIRMWARE_BLOCK_SIZE         = 16
BROADCAST_ADDRESS           = 255
NODE_SENSOR_ID              = 255
C_PRESENTATION              = 0
C_SET                       = 1
C_REQ                       = 2
C_INTERNAL                  = 3
C_STREAM                    = 4
V_TEMP                      = 0
V_HUM                       = 1
V_LIGHT                     = 2
V_DIMMER                    = 3
V_PRESSURE                  = 4
V_FORECAST                  = 5
V_RAIN                      = 6
V_RAINRATE                  = 7
V_WIND                      = 8
V_GUST                      = 9
V_DIRECTION                 = 10
V_UV                        = 11
V_WEIGHT                    = 12
V_DISTANCE                  = 13
V_IMPEDANCE                 = 14
V_ARMED                     = 15
V_TRIPPED                   = 16
V_WATT                      = 17
V_KWH                       = 18
V_SCENE_ON                  = 19
V_SCENE_OFF                 = 20
V_HEATER                    = 21
V_HEATER_SW                 = 22
V_LIGHT_LEVEL               = 23
V_VAR1                      = 24
V_VAR2                      = 25
V_VAR3                      = 26
V_VAR4                      = 27
V_VAR5                      = 28
V_UP                        = 29
V_DOWN                      = 30
V_STOP                      = 31
V_IR_SEND                   = 32
V_IR_RECEIVE                = 33
V_FLOW                      = 34
V_VOLUME                    = 35
V_LOCK_STATUS               = 36
I_BATTERY_LEVEL             = 0
I_TIME                      = 1
I_VERSION                   = 2
I_ID_REQUEST                = 3
I_ID_RESPONSE               = 4
I_INCLUSION_MODE            = 5
I_CONFIG                    = 6
I_PING                      = 7
I_PING_ACK                  = 8
I_LOG_MESSAGE               = 9
I_CHILDREN                  = 10
I_SKETCH_NAME               = 11
I_SKETCH_VERSION            = 12
I_REBOOT                    = 13
S_DOOR                      = 0
S_MOTION                    = 1
S_SMOKE                     = 2
S_LIGHT                     = 3
S_DIMMER                    = 4
S_COVER                     = 5
S_TEMP                      = 6
S_HUM                       = 7
S_BARO                      = 8
S_WIND                      = 9
S_RAIN                      = 10
S_UV                        = 11
S_WEIGHT                    = 12
S_POWER                     = 13
S_HEATER                    = 14
S_DISTANCE                  = 15
S_LIGHT_LEVEL               = 16
S_ARDUINO_NODE              = 17
S_ARDUINO_REPEATER_NODE     = 18
S_LOCK                      = 19
S_IR                        = 20
S_WATER                     = 21
S_AIR_QUALITY               = 22
ST_FIRMWARE_CONFIG_REQUEST  = 0
ST_FIRMWARE_CONFIG_RESPONSE = 1
ST_FIRMWARE_REQUEST         = 2
ST_FIRMWARE_RESPONSE        = 3
ST_SOUND                    = 4
ST_IMAGE                    = 5
P_STRING                    = 0
P_BYTE                      = 1
P_INT16                     = 2
P_UINT16                    = 3
P_LONG32                    = 4
P_ULONG32                   = 5
P_CUSTOM                    = 6

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
  command = C_INTERNAL
  acknowledge = 0 #no ack
  type = I_TIME
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
      destination = BROADCAST_ADDRESS
      sensor = NODE_SENSOR_ID
      command = C_INTERNAL
      acknowledge = 0
      type = I_ID_RESPONSE
      payload = id
      td = encode destination, sensor, command, acknowledge, type, payload
      log.info "-> #{td.toString()}"
      gw.write td
      callback null


sendConfig = (destination, gw)->
  payload = "I"
  sensor = NODE_SENSOR_ID
  command = C_INTERNAL
  acknowledge = 0
  type = I_CONFIG
  td = encode destination, sensor, command, acknowledge, type, payload
  log.info "-> #{td.toString()}"
  gw.write td

saveRebootRequest = (destination)-> mysensors_db.saveRebootRequest destination, db

checkRebootRequest = (destination, db, gw)-> mysensors_db.checkRebootRequest destination, db, gw

sendRebootMessage = (destination, gw)->
  sensor = NODE_SENSOR_ID
  command = C_INTERNAL
  acknowledge = 0
  type = I_REBOOT
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




    if command == C_STREAM
      log.info "Received serial message 'C_STREAM'"
      payload = []
      for i in [0..rawpayload.length] by 2
        payload.push(parseInt(rawpayload.substring(i, i + 2), 16))
    else
      payload = rawpayload

    switch command
      when C_PRESENTATION
        log.info "Received serial message 'C_PRESENTATION'"

        if sensor == NODE_SENSOR_ID
          mysensors_db.saveProtocol sender, payload, ->
            mysensors_db.saveSensor sender, sensor, type, callback
        else
          mysensors_db.saveSensor sender, sensor, type, callback

      when C_SET
        log.info "Received serial message 'C_SET'"
        if payload != null and payload != "null" and payload != ""
          mysensors_db.saveValue sender, sensor, type, payload, (err, record)->
            log.info "publishing updated value for node #{sender} sensor #{sensor} (#{type})"
            config.statusExchange.publish "#{type}", record
            callback null
        else
          log.info "payload is null, ignoring"
          callback null

      when C_REQ
        log.info "Received serial message 'C_REQ'"
        log.info "Requesting value for node #{sender} sensor id #{sensor}"
        callback null

      when C_INTERNAL
        switch type
          when I_BATTERY_LEVEL
            log.info "Received serial message 'I_BATTERY_LEVEL'"
            mysensors_db.saveBatteryLevel sender, payload, callback

          when I_TIME
            log.info "Received serial message 'I_TIME'"
            sendTime sender, sensor, gw
            callback null

          when I_VERSION
            log.info "Received serial message 'I_VERSION'"
            callback null

          when I_ID_REQUEST
            log.info "Received serial message 'I_ID_REQUEST'"
            sendNextAvailableSensorId gw, callback

          when I_ID_RESPONSE
            log.info "Received serial message 'I_ID_RESPONSE'"
            callback null

          when I_INCLUSION_MODE
            log.info "Received serial message 'I_INCLUSION_MODE'"
            callback null

          when I_CONFIG
            log.info "Received serial message 'I_CONFIG'"
            sendConfig sender, gw
            callback null

          when I_PING
            log.info "Received serial message 'I_PING'"
            callback null

          when I_PING_ACK
            log.info "Received serial message 'I_PING_ACK'"
            callback null

          when I_LOG_MESSAGE
            log.info "Received serial message 'I_LOG_MESSAGE'"
            callback null

          when I_CHILDREN
            log.info "Received serial message 'I_CHILDREN'"
            callback null

          when I_SKETCH_NAME
            log.info "Received serial message 'I_SKETCH_NAME'"
            mysensors_db.saveSketchName sender, payload, callback

          when I_SKETCH_VERSION
            log.info "Received serial message 'I_SKETCH_VERSION'"
            mysensors_db.saveSketchVersion sender, payload, callback

          when I_REBOOT
            log.info "Received serial message 'I_REBOOT'"
            callback null

      when C_STREAM
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
exports.C_PRESENTATION = C_PRESENTATION
exports.C_SET = C_SET
exports.C_REQ = C_REQ
exports.C_INTERNAL = C_INTERNAL
exports.C_STREAM = C_STREAM
exports.V_TEMP = V_TEMP
exports.V_HUM = V_HUM
exports.V_LIGHT = V_LIGHT
exports.V_DIMMER = V_DIMMER
exports.V_PRESSURE = V_PRESSURE
exports.V_FORECAST = V_FORECAST
exports.V_RAIN = V_RAIN
exports.V_RAINRATE = V_RAINRATE
exports.V_WIND = V_WIND
exports.V_GUST = V_GUST
exports.V_DIRECTION = V_DIRECTION
exports.V_UV = V_UV
exports.V_WEIGHT = V_WEIGHT
exports.V_DISTANCE = V_DISTANCE
exports.V_IMPEDANCE = V_IMPEDANCE
exports.V_ARMED = V_ARMED
exports.V_TRIPPED = V_TRIPPED
exports.V_WATT = V_WATT
exports.V_KWH = V_KWH
exports.V_SCENE_ON = V_SCENE_ON
exports.V_SCENE_OFF = V_SCENE_OFF
exports.V_HEATER = V_HEATER
exports.V_HEATER_SW = V_HEATER_SW
exports.V_LIGHT_LEVEL = V_LIGHT_LEVEL
exports.V_VAR1 = V_VAR1
exports.V_VAR2 = V_VAR2
exports.V_VAR3 = V_VAR3
exports.V_VAR4 = V_VAR4
exports.V_VAR5 = V_VAR5
exports.V_UP = V_UP
exports.V_DOWN = V_DOWN
exports.V_STOP = V_STOP
exports.V_IR_SEND = V_IR_SEND
exports.V_IR_RECEIVE = V_IR_RECEIVE
exports.V_FLOW = V_FLOW
exports.V_VOLUME = V_VOLUME
exports.V_LOCK_STATUS = V_LOCK_STATUS
exports.I_BATTERY_LEVEL = I_BATTERY_LEVEL
exports.I_TIME = I_TIME
exports.I_VERSION = I_VERSION
exports.I_ID_REQUEST = I_ID_REQUEST
exports.I_ID_RESPONSE = I_ID_RESPONSE
exports.I_INCLUSION_MODE = I_INCLUSION_MODE
exports.I_CONFIG = I_CONFIG
exports.I_PING = I_PING
exports.I_PING_ACK = I_PING_ACK
exports.I_LOG_MESSAGE = I_LOG_MESSAGE
exports.I_CHILDREN = I_CHILDREN
exports.I_SKETCH_NAME = I_SKETCH_NAME
exports.I_SKETCH_VERSION = I_SKETCH_VERSION
exports.I_REBOOT = I_REBOOT
exports.S_DOOR = S_DOOR
exports.S_MOTION = S_MOTION
exports.S_SMOKE = S_SMOKE
exports.S_LIGHT = S_LIGHT
exports.S_DIMMER = S_DIMMER
exports.S_COVER = S_COVER
exports.S_TEMP = S_TEMP
exports.S_HUM = S_HUM
exports.S_BARO = S_BARO
exports.S_WIND = S_WIND
exports.S_RAIN = S_RAIN
exports.S_UV = S_UV
exports.S_WEIGHT = S_WEIGHT
exports.S_POWER = S_POWER
exports.S_HEATER = S_HEATER
exports.S_DISTANCE = S_DISTANCE
exports.S_LIGHT_LEVEL = S_LIGHT_LEVEL
exports.S_ARDUINO_NODE = S_ARDUINO_NODE
exports.S_ARDUINO_REPEATER_NODE = S_ARDUINO_REPEATER_NODE
exports.S_LOCK = S_LOCK
exports.S_IR = S_IR
exports.S_WATER = S_WATER
exports.S_AIR_QUALITY = S_AIR_QUALITY
exports.ST_FIRMWARE_CONFIG_REQUEST = ST_FIRMWARE_CONFIG_REQUEST
exports.ST_FIRMWARE_CONFIG_RESPONSE = ST_FIRMWARE_CONFIG_RESPONSE
exports.ST_FIRMWARE_REQUEST = ST_FIRMWARE_REQUEST
exports.ST_FIRMWARE_RESPONSE = ST_FIRMWARE_RESPONSE
exports.ST_SOUND = ST_SOUND
exports.ST_IMAGE = ST_IMAGE
exports.P_STRING = P_STRING
exports.P_BYTE = P_BYTE
exports.P_INT16 = P_INT16
exports.P_UINT16 = P_UINT16
exports.P_LONG32 = P_LONG32
exports.P_ULONG32 = P_ULONG32
exports.P_CUSTOM = P_CUSTOM
