var dbc = require('mongodb').MongoClient;
var async = require('async');
var _ = require("underscore");
var log = require("winston");

// connect to mongodb
function connectToDatabase(callback){
  var parser = new require('inireader').IniReader();
  parser.load('../config/site.ini');
  var dbAddress = parser.param('mysensors.dbAddress');
  var dbPort = parser.param('mysensors.dbPort');
  var dbName = parser.param('mysensors.dbName');

  dbc.connect('mongodb://' + dbAddress + ':' + dbPort + '/' + dbName, function(err, db) {
    if(err) {
      log.error('Error connecting to database at mongodb://' + dbAddress + ':' + dbPort + '/' + dbName);
      callback(err);
    }
    log.info('Connected to database at mongodb://' + dbAddress + ':' + dbPort + '/' + dbName);
    callback(null,{db: db})
  });
};
function getNode(db, nodeId, callback){
  db.collection('node', function(err, c) {
    if (err || ! c) callback(err)

    // query for all sensor nodes
    else c.findOne({"id": nodeId}, function(err, node) {
      if( err || !node) callback(err);
      else callback(null,node);
    });
  });
}
function sensorDataFetcher(db, nodeId, sensorId, start){
  return function(callback){
    db.collection("Value-"+nodeId+"-"+sensorId, function(err, c) {
      if (err || ! c) console.log(err);
      else {
        var mapFunction = function() {
          var out = Math.floor(this.timestamp % 30)
          emit(out, parseInt(this.value,10));
        }
        var reduceFunction =  function(ids, number) {
          return Array.avg(number);
        };
        c.mapReduce(mapFunction,reduceFunction,
          {
            out: { inline: 1 },
            query: { "timestamp":{$gt: start}}
          },
          function(err, sensorReadings) {
            if(err) {
              callback(err);
            }
            else {
              log.info("successfully fetched data for "+"Value-"+nodeId+"-"+sensorId);
              callback(null,sensorReadings);
            }
        });
      }
    });
  }
}
function querySensor(db, connection, deliveryInfo, message) {
  log.info("querying for node "+message.node)
  getNode(db,message.node,function(err,node){
    if(!err){
      log.info("node found querying for sensors");
      fetchers = []
      node.sensor.forEach(function(sensorType, index){
        if([17,18].indexOf(sensorType) === -1){
          fetchers.push(sensorDataFetcher(db,node.id,(index-1),message.start));
        }
      });
      async.parallel(fetchers,function(err,results){
        if(err){
          log.error(err);
        }
        else{
          replyTo = deliveryInfo.replyTo;
          log.debug("sending snapshot back on queue "+replyTo);
          connection.publish(replyTo,results);
        }
      });
    }
    else{
      log.error(err);
    }
  });
}
function dumpSensorData(db, connection, deliveryInfo) {
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
                    value: sensorReading.value,
                    internalSensorId: index-1
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
                value: reading.value,
                internalSensorId: reading.internalSensorId
              }
              return result;
            },{});
            replyTo = deliveryInfo.replyTo;
            log.debug("sending snapshot back on queue "+replyTo);
            connection.publish(replyTo,result);
          }
        });
      });
    });
  });
};

exports.dumpSensorData = dumpSensorData
exports.connectToDatabase = connectToDatabase
exports.querySensor = querySensor