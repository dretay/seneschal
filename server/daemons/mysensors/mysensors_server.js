var amqp = require('amqp');
var dbc = require('mongodb').MongoClient;
var IniReader = require('inireader');
var async = require('async');
var _ = require("underscore");

// read in configuration
var parser = new IniReader.IniReader();
parser.load('../config/site.ini');

var dbAddress = parser.param('mysensors.dbAddress');
var dbPort = parser.param('mysensors.dbPort');
var dbName = parser.param('mysensors.dbName');

// connect to mongodb
dbc.connect('mongodb://' + dbAddress + ':' + dbPort + '/' + dbName, function(err, db) {
  if(err) {
    console.log('Error connecting to database at mongodb://' + dbAddress + ':' + dbPort + '/' + dbName);
    return;
  }
  console.log('Connected to database at mongodb://' + dbAddress + ':' + dbPort + '/' + dbName);

  // connect to the amqp broker
  var rabbitmqUsername = parser.param('rabbitmq.username');
  var rabbitmqPassword = parser.param('rabbitmq.password');
  var rabbitmqHost = parser.param('rabbitmq.host');
  var connection = amqp.createConnection({url: "amqp://"+rabbitmqUsername+":"+rabbitmqPassword+"@"+rabbitmqHost+":5672" });
  connection.addListener('ready', function () {
    connection.queue('mysensors.cmd', function (q) {
      connection.exchange("mysensors.cmd",{type: "direct", durable: true, autoDelete: false}, function(directExchange){
        q.bind(directExchange, '', function(){
          q.subscribe(function (message, headers, deliveryInfo, messageObject) {
            message = JSON.parse(message.data.toString());
            // setup the query the node db for all sensor nodes
            db.collection('node', function(err, c) {
              if (err || ! c) console.log(err);
              // query for all sensor nodes
              else c.find({"id":{$gt: 0}}).toArray(function(err, nodes) {
                if( err || !nodes) console.log(err);
                else nodes.forEach( function(node) {
                  fetchers = []
                  node.sensor.forEach(function(sensorType, index){
                    if([17,18].indexOf(sensorType) === -1){
                      // build the fetchers to go query mongo in parallel for the node value
                      fetchers.push(function(callback){
                        db.collection("Value-"+node.id+"-"+(index-1), function(err, c) {
                          if (err || ! c) console.log(err);
                          else c.findOne({},{"sort":[["timestamp","desc"]]}, function(err, sensorReading) {
                            callback(null, {
                              node: node.id,
                              sensorType: sensorType,
                              timestamp: sensorReading.timestamp,
                              value: sensorReading.value
                            });
                          });
                        });
                      });
                    }
                  });
                  //get results with no more than 5 concurrent queries
                  async.parallelLimit(fetchers, 5, function(err, readings){
                    if(err){
                      console.log(err);
                    }
                    else{
                      // reduce the results to per-node readings
                      result = _.reduceRight(readings, function(result,reading){
                        if(!result[reading.node]) result[reading.node] = {}
                        result[reading.node][reading.sensorType] = {
                          timestamp: reading.timestamp,
                          value: reading.value
                        }
                        return result;
                      },{});
                      replyTo = deliveryInfo.replyTo;
                      console.log("sending snapshot back on queue "+replyTo);
                      connection.publish(replyTo,result);
                    }
                  });
                });
              });
            });
          });
        });
      });
    });
  });
});
