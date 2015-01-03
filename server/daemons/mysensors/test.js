var async = require('async');
var serial_gateway = require("./serial_gateway");
var rabbitmq = require("./rabbitmq");
var log = require("winston");

async.waterfall([
  rabbitmq.connectToBroker,
  serial_gateway.connectToGateway
  ],function(err,config){
  if(err){}
  else{
    var node_id = 2;
    var sensor_id = 2;
    var message_type = serial_gateway.C_SET;
    var ack = 1;
    var sub_type = serial_gateway.V_LOCK_STATUS;
    // var payload = 1;
    var td = serial_gateway.encode(node_id, sensor_id, message_type, ack, sub_type, null);
    log.info('-> ' + td.toString());
    config.gw.write(td);

  }
});
