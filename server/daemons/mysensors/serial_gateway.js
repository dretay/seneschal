var _ = require("underscore");
var log = require("winston");
var mysensors_db = require("./mysensors_db");
var async = require('async');

const fwSketches          = [ ];
const fwDefaultType         = 0xFFFF; // index of hex file from array above (0xFFFF

const FIRMWARE_BLOCK_SIZE     = 16;
const BROADCAST_ADDRESS       = 255;
const NODE_SENSOR_ID        = 255;

const C_PRESENTATION        = 0;
const C_SET             = 1;
const C_REQ             = 2;
const C_INTERNAL          = 3;
const C_STREAM            = 4;

const V_TEMP            = 0;
const V_HUM             = 1;
const V_LIGHT           = 2;
const V_DIMMER            = 3;
const V_PRESSURE          = 4;
const V_FORECAST          = 5;
const V_RAIN            = 6;
const V_RAINRATE          = 7;
const V_WIND            = 8;
const V_GUST            = 9;
const V_DIRECTION         = 10;
const V_UV              = 11;
const V_WEIGHT            = 12;
const V_DISTANCE          = 13;
const V_IMPEDANCE         = 14;
const V_ARMED           = 15;
const V_TRIPPED           = 16;
const V_WATT            = 17;
const V_KWH             = 18;
const V_SCENE_ON          = 19;
const V_SCENE_OFF         = 20;
const V_HEATER            = 21;
const V_HEATER_SW         = 22;
const V_LIGHT_LEVEL         = 23;
const V_VAR1            = 24;
const V_VAR2            = 25;
const V_VAR3            = 26;
const V_VAR4            = 27;
const V_VAR5            = 28;
const V_UP              = 29;
const V_DOWN            = 30;
const V_STOP            = 31;
const V_IR_SEND           = 32;
const V_IR_RECEIVE          = 33;
const V_FLOW            = 34;
const V_VOLUME            = 35;
const V_LOCK_STATUS         = 36;

const I_BATTERY_LEVEL       = 0;
const I_TIME            = 1;
const I_VERSION           = 2;
const I_ID_REQUEST          = 3;
const I_ID_RESPONSE         = 4;
const I_INCLUSION_MODE        = 5;
const I_CONFIG            = 6;
const I_PING            = 7;
const I_PING_ACK          = 8;
const I_LOG_MESSAGE         = 9;
const I_CHILDREN          = 10;
const I_SKETCH_NAME         = 11;
const I_SKETCH_VERSION        = 12;
const I_REBOOT            = 13;

const S_DOOR            = 0;
const S_MOTION            = 1;
const S_SMOKE           = 2;
const S_LIGHT           = 3;
const S_DIMMER            = 4;
const S_COVER           = 5;
const S_TEMP            = 6;
const S_HUM             = 7;
const S_BARO            = 8;
const S_WIND            = 9;
const S_RAIN            = 10;
const S_UV              = 11;
const S_WEIGHT            = 12;
const S_POWER           = 13;
const S_HEATER            = 14;
const S_DISTANCE          = 15;
const S_LIGHT_LEVEL         = 16;
const S_ARDUINO_NODE        = 17;
const S_ARDUINO_REPEATER_NODE   = 18;
const  S_LOCK           = 19;
const  S_IR             = 20;
const  S_WATER            = 21;
const  S_AIR_QUALITY        = 22;

const ST_FIRMWARE_CONFIG_REQUEST  = 0;
const ST_FIRMWARE_CONFIG_RESPONSE = 1;
const ST_FIRMWARE_REQUEST     = 2;
const ST_FIRMWARE_RESPONSE      = 3;
const ST_SOUND            = 4;
const ST_IMAGE            = 5;

const P_STRING            = 0;
const P_BYTE            = 1;
const P_INT16           = 2;
const P_UINT16            = 3;
const P_LONG32            = 4;
const P_ULONG32           = 5;
const P_CUSTOM            = 6;

var appendedString="";
var writeQueue = async.queue(function (params, callback) {
    rfReceived(params.appendedString.trim(), params.config, callback);
}, 1);

function encode(destination, sensor, command, acknowledge, type, payload) {
  var msg = destination.toString(10) + ";" + sensor.toString(10) + ";" + command.toString(10) + ";" + acknowledge.toString(10) + ";" + type.toString(10) + ";";
  if (command == 4) {
    for (var i = 0; i < payload.length; i++) {
      if (payload[i] < 16)
        msg += "0";
      msg += payload[i].toString(16);
    }
  } else {
    msg += payload;
  }
  msg += '\n';
  return msg.toString();
}

function saveProtocol(sender, payload) {
  mysensors_db.saveProtocol(sender,payload);
}

function saveSensor(sender, sensor, type) {
  mysensors_db.saveSensor(sender, sensor, type);
}

function saveValue(sender, sensor, type, payload, config) {
  mysensors_db.saveValue(sender, sensor, type, payload, function(){
    log.info("publishing updated sensor value"+ config.fanoutExchange);
    config.fanoutExchange.publish("", _.extend({
      sender: sender.toString(),
      sensor: sensor.toString()
    },payload));
  });
}

function saveBatteryLevel(sender, payload) {
  mysensors_db.saveBatteryLevel(sender, payload);
}

function saveSketchName(sender, payload) {
  mysensors_db.saveSketchName(sender, payload);
}

function saveSketchVersion(sender, payload) {
  mysensors_db.saveSketchVersion(sender, payload);
}

function sendTime(destination, sensor, gw) {
  var payload = new Date().getTime();
  var command = C_INTERNAL;
  var acknowledge = 0; // no ack
  var type = I_TIME;
  var td = encode(destination, sensor, command, acknowledge, type, payload);
  log.info('-> ' + td.toString());
  gw.write(td);
}

function sendNextAvailableSensorId(gw,callback) {
  mysensors_db.sendNextAvailableSensorId(function(id){
    console.log("sending back id "+id);
    var destination = BROADCAST_ADDRESS;
    var sensor = NODE_SENSOR_ID;
    var command = C_INTERNAL;
    var acknowledge = 0; // no ack
    var type = I_ID_RESPONSE;
    var payload = id;
    var td = encode(destination, sensor, command, acknowledge, type, payload);
    log.info('-> ' + td.toString());
    gw.write(td);
    callback(null);
  });
}

function sendConfig(destination, gw) {
  var payload = "I";
  var sensor = NODE_SENSOR_ID;
  var command = C_INTERNAL;
  var acknowledge = 0; // no ack
  var type = I_CONFIG;
  var td = encode(destination, sensor, command, acknowledge, type, payload);
  log.info('-> ' + td.toString());
  gw.write(td);
}



function saveRebootRequest(destination) {
  mysensors_db.saveRebootRequest(destination, db);
}

function checkRebootRequest(destination, db, gw) {
  mysensors_db.checkRebootRequest(destination, db, gw);
}

function sendRebootMessage(destination, gw) {
  var sensor = NODE_SENSOR_ID;
        var command = C_INTERNAL;
        var acknowledge = 0; // no ack
        var type = I_REBOOT;
        var payload = "";
        var td = encode(destination, sensor, command, acknowledge, type, payload);
        log.info('-> ' + td.toString());
        gw.write(td);
}


function appendData(str, config) {
    pos=0;
    while (str.charAt(pos) != '\n' && pos < str.length) {
        appendedString=appendedString+str.charAt(pos);
        pos++;
    }
    if (str.charAt(pos) == '\n') {
        writeQueue.push({appendedString: appendedString, config: config}, function (err) {
          if(err){
            log.error("Encountered error when processing gateway queue: "+err);
          }
        });
        appendedString="";
    }
    if (pos < str.length) {
        appendData(str.substr(pos+1,str.length-pos-1), config);
    }
}

function rfReceived(data, config, callback) {
  gw = config.gw
  if ((data != null) && (data != "")) {
    log.info('<- ' + data);
    // decoding message
    var datas = data.toString().split(";");
    var sender = +datas[0];
    var sensor = +datas[1];
    var command = +datas[2];
    var ack = +datas[3];
    var type = +datas[4];
                var rawpayload="";
                if (datas[5]) {
                  rawpayload = datas[5].trim();
    }
    var payload;
    if (command == C_STREAM) {
      payload = [];
      for (var i = 0; i < rawpayload.length; i+=2)
        payload.push(parseInt(rawpayload.substring(i, i + 2), 16));
    } else {
      payload = rawpayload;
    }
    log.info("Executing "+command+" in rfReceived"+typeof callback);
    // decision on appropriate response
    switch (command) {
    case C_PRESENTATION:
      if (sensor == NODE_SENSOR_ID)
        mysensors_db.saveProtocol(sender, payload, function(){
          mysensors_db.saveSensor(sender, sensor, type, callback);
        });
      else{
        mysensors_db.saveSensor(sender, sensor, type, callback);
      }
      break;
    case C_SET:
      mysensors_db.saveValue(sender, sensor, type, payload, function(record){
        config.fanoutExchange.publish("", record);
        callback(null);
      });

      break;
    case C_REQ:
      break;
    case C_INTERNAL:
      switch (type) {
      case I_BATTERY_LEVEL:
        mysensors_db.saveBatteryLevel(sender, payload, callback);
        break;
      case I_TIME:
        sendTime(sender, sensor, gw);
        callback(null);
        break;
      case I_VERSION:
        callback(null);
        break;
      case I_ID_REQUEST:
        sendNextAvailableSensorId(gw, callback);
        break;
      case I_ID_RESPONSE:
        callback(null);
        break;
      case I_INCLUSION_MODE:
        callback(null);
        break;
      case I_CONFIG:
        sendConfig(sender, gw);
        callback(null);
        break;
      case I_PING:
        callback(null);
        break;
      case I_PING_ACK:
        callback(null);
        break;
      case I_LOG_MESSAGE:
        callback(null);
        break;
      case I_CHILDREN:
        callback(null);
        break;
      case I_SKETCH_NAME:
        mysensors_db.saveSketchName(sender, payload, callback);
        break;
      case I_SKETCH_VERSION:
        mysensors_db.saveSketchVersion(sender, payload, callback);
        break;
      case I_REBOOT:
        callback(null);
        break;
      }
      break;
    case C_STREAM:
      callback(null);
      break;
    }
    // checkRebootRequest(sender, db, gw);
  }
}
function connectToGateway(config, callback){
  // read in configuration
  var parser = new require('inireader').IniReader();
  parser.load('../config/site.ini');

  var SerialPort = require('serialport').SerialPort;
  var gwPort = parser.param('mysensors.gwPort');
  var gwBaud = parser.param('mysensors.gwBaud');
  gw = new SerialPort(gwPort, { baudrate: gwBaud });
  config = _.extend({gw: gw},config)
  gw.open(function(err){
    if(err){
      callback(err);
    }else{
      log.info('connected to serial gateway at ' + gwPort);
      callback(null,config);
      gw.on('data', function(rd) {
        appendData(rd.toString(), config);
      }).on('end', function() {
        log.info('disconnected from gateway');
      }).on('error', function() {
        log.error('connection error');
      });
    }
  });
}

exports.connectToGateway = connectToGateway;
