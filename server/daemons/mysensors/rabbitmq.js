var _ = require("underscore");
var amqp = require('amqp');
var mysensors_db = require("./mysensors_db")
var log = require("winston");

// connect to the amqp broker
function connectToBroker(callback){
  var parser = new require('inireader').IniReader();
  parser.load('../config/site.ini');
  var rabbitmqUsername = parser.param('rabbitmq.username');
  var rabbitmqPassword = parser.param('rabbitmq.password');
  var rabbitmqHost = parser.param('rabbitmq.host');
  var connection = amqp.createConnection({url: "amqp://"+rabbitmqUsername+":"+rabbitmqPassword+"@"+rabbitmqHost+":5672" });
  connection.addListener('ready', function () {
    log.info("successfully connected to amqp broker");
    setupSubscriptions({amqpConnection: connection}, callback);
  });
};



function setupSubscriptions(config, callback){
  config.amqpConnection.exchange("mysensors.status",{type: "fanout", durable: true, autoDelete: false}, function(fanoutExchange){
    config.amqpConnection.queue('mysensors.cmd', function (q) {
      config.amqpConnection.exchange("mysensors.cmd",{type: "direct", durable: true, autoDelete: false}, function(directExchange){
          q.bind(directExchange, '', function(){
            q.subscribe(function (message, headers, deliveryInfo, messageObject) {
              message = JSON.parse(message.data.toString());
              if(message.cmd === "getAllSensors"){
                mysensors_db.getAllSensors(function(err, sensors){
                  config.amqpConnection.publish(deliveryInfo.replyTo,sensors);
                });
              }
              else if(message.cmd === "dumpSensorData"){
                mysensors_db.getNewestReadings(function(err, readings){
                  config.amqpConnection.publish(deliveryInfo.replyTo,readings);
                });
              }
              else if(message.cmd === "getBinnedReadings"){
                mysensors_db.getBinnedReadings(message.nodes, message.binUnit, message.timeFrame, function(err, readings){
                  config.amqpConnection.publish(deliveryInfo.replyTo,readings);
                });
              }
            });
            log.info("completed binding and subscribing to broker")
            callback(null,_.extend({fanoutExchange: fanoutExchange },config));
          });
      });
    });
  });
}
exports.connectToBroker = connectToBroker
