var async = require('async');
var serial_gateway = require("./serial_gateway");
var rabbitmq = require("./rabbitmq");
var log = require("winston");
// var mysensors_db = require("./mysensors_db");


// mysensors_db.getBinnedReadings([{id: 1,sensors:[0]}],'hour',function(err,results){
//   console.log(JSON.stringify(results));
// });

async.waterfall([
  rabbitmq.connectToBroker,
  serial_gateway.connectToGateway
  ],function(err,config){
  if(err){
    console.log(err);
  }else{
    log.info("server startup complete")
  }
});