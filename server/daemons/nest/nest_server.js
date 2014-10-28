var Firebase = require('firebase');
var IniReader = require('inireader');
var amqp = require('amqp');

var parser = new IniReader.IniReader();
parser.load('../config/site.ini');

var rabbitmqUsername = parser.param('rabbitmq.username');
var rabbitmqPassword = parser.param('rabbitmq.password');
var rabbitmqHost = parser.param('rabbitmq.host');
var connection = amqp.createConnection({url: "amqp://"+rabbitmqUsername+":"+rabbitmqPassword+"@"+rabbitmqHost+":5672" });

var access_token = parser.param('nest.password');
var ref = new Firebase('wss://developer-api.nest.com');
ref.auth(access_token);

var snapshot = {}

connection.on('error', function (exception) {
    message = String(exception.message);
    console.log ("ERROR: "+message);
    process.exit(0);
  });

connection.addListener('ready', function () {
  connection.exchange("nest.status",{type: "fanout", durable: true, autoDelete: false}, function(fanoutExchange){
    ref.on('value', function(newSnapshot) {
      snapshot = newSnapshot;
      fanoutExchange.publish("", newSnapshot.val());
      console.log("new snapshot stored");
    });
  });

  connection.queue('nest.cmd', function (q) {
    connection.exchange("nest.cmd",{type: "direct", durable: true, autoDelete: false}, function(directExchange){
      q.bind(directExchange, '', function(){
        q.subscribe(function (message, headers, deliveryInfo, messageObject) {
          message = JSON.parse(message.data.toString());
          if(message.cmd === "snapshot"){
            replyTo = deliveryInfo.replyTo;
            console.log("sending snapshot back on queue "+replyTo);
            connection.publish(replyTo,snapshot.val());
          }
          else if(message.cmd === "changeTemp"){
            console.log("changing temperature to "+message.targetTemperature);
            device_id = snapshot.val().devices.thermostats[message.device_id].device_id
            ref.child("/devices/thermostats/"+device_id+"/target_temperature_f").set(message.targetTemperature, function(err){
              if(err){
                console.log ("Error setting temperature "+err)
              }else{
                console.log ("Updated target temperature to "+message.targetTemperature);
              }
            });
          }
        });
      });
    });
  });

});
