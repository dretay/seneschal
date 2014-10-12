var Knex = require('./db').Knex;
var log = require("winston");
var _ = require("underscore");

function createNodeIfMissing(id,callback){
  var q = Knex('nodes');
  q.count('id');
  q.where('id','=',id);
  q.then(function(result){
    if (result[0].count == 0){
      log.info("Node not found, creating node with id "+id);
      q.insert({
        id: id
      }).then(function(){
        callback(null);
      });
    }else{
      callback(null);
    }
  })
}
function saveProtocol(sender, payload, callback) {
  if(isNaN(parseFloat(sender))){
    callback("protocol is nan, can't save");
  } else{
  createNodeIfMissing(sender,function(){
    var q = Knex('nodes');
    q.where('id','=',sender);
    q.update('protocol',payload);
    q.then(function(){
      log.info("Finished updating "+sender+" protocol to "+payload);
      callback(null);
    },function(err){
      log.error("Failed to update "+sender+" protocol to "+payload+": "+err);
      callback(err);
    });
  });
  }
}

function saveSensor(sender, sensor, type,callback) {
  createNodeIfMissing(sender,function(){
    var q = Knex('sensors');
    q.select('sensortype');
    q.where('node','=',sender);
    q.then(function(sensors){
      if(!_.contains(sensors, type)){
        q.insert({
          node: sender,
          sensortype: type,
          sensorindex: sensor
        });
        q.then(function(){
          log.info("Inserted a new sensor for "+sender+" indexed as "+sensor+" a ("+type+")");
          callback(null);
        },function(err){
          log.error("Failed to insert a new sensor for "+sender+" indexed as "+sensor+" a ("+type+"): "+err);
          callback(err);
        });
      }
    });
  });
}

function saveValue(sender, sensor, type, payload,callback) {
    var q = Knex('readings');
    record = {
      node:sender,
      sensorindex: sensor
    };
    // is it a number of some kind
    if (!_.isNaN(parseFloat(payload))){
      record.real_value = parseFloat(payload);
      log.info("payload is a number, cast it to "+record.real_value);
    }
    q.insert(record);
    q.then(function(){
      log.info("Inserted "+payload+" into node "+sender+"'s sensor "+sensor+"("+type+")");
      callback(record);
    },function(err){
      log.error("Failed to insert "+payload+" into node "+sender+"'s sensor "+sensor+"("+type+")"+": "+err);
      callback(err);
    });
}

function saveBatteryLevel(sender, payload, db,callback) {
  // var cn = "BatteryLevel-" + sender.toString();
  // db.createCollection(cn, function(err, c) {
  //   c.save({
  //     'timestamp': new Date().getTime(),
  //     'value': payload
  //   }, function(err, result) {
  //     if (err)
  //       log.error("Error writing battery level to database");
  //   });
  // });
  log.warn("mysensors_db::saveBatteryLevel not implemented");
  callback(null);

}

function saveSketchName(sender, payload,callback) {
  createNodeIfMissing(sender,function(){
    var q = Knex('nodes');
    q.where('id','=',sender);
    q.update('sketchname',payload);
    q.then(function(){
      log.info("Saved sketch name for "+sender);
      callback(null);
    },function(err){
      log.error("Failed to save sketch name for "+sender+": "+err);
      callback(err);
    });
  });
}

function saveSketchVersion(sender, payload,callback) {
  createNodeIfMissing(sender,function(){
    var q = Knex('nodes');
    q.where('id','=',sender);
    q.update('sketchversion',payload);
    q.then(function(){
      log.info("Saved sketch version for "+sender);
      callback(null);
    },function(err){
      log.error("Failed to save sketch version for "+sender);
      callback(err);
    });
  });
}
function saveRebootRequest(destination, db,callback) {
  // db.collection('node', function(err, c) {
  //   c.update({
  //     'id': destination
  //   }, {
  //     $set: {
  //       'reboot': 1
  //     }
  //   }, function(err, result) {
  //     if (err)
  //       log.error("Error writing reboot request to database");
  //   });
  // });
  log.warn("mysensors_db::saveRebootRequest not implemented");
  callback(null);

}

function checkRebootRequest(destination, db, gw,callback) {
  // db.collection('node', function(err, c) {
  //   c.find({
  //     'id': destination
  //   }, function(err, item) {
  //     if (err)
  //       log.error('Error checking reboot request');
  //     else if (item.reboot == 1)
  //       sendRebootMessage(destination, gw);
  //   });
  // });
  log.warn("mysensors_db::checkRebootRequest not implemented");
  callback(null);

}
function sendNextAvailableSensorId(callback) {
  var q = Knex('nodes');
  q.returning('id');
  q.insert({
    protocol:null,
    sketchname: null,
    sketchversion: null
  })
  q.then(function(ids){
    var id  = ids[0];
    log.info("Created new sensor with id"+id);
    callback(id);
  },function(err){
    log.error("Failed to create new sensor: "+err);
    callback(err);
  });
}
function getAllSensors(callback){
  var q = Knex('sensors')
  q.select('nodes.sketchname','sensors.node','sensors.sensorindex','sensortypes.longname')
  q.innerJoin('sensortypes','sensors.sensortype','sensortypes.id')
  q.innerJoin('nodes','sensors.node','nodes.id')
  q.then(function(sensors){
    callback(null,sensors);
  },function(err){
    log.error("Failed to get list of available sensors: "+err);
    callback(err);
  });

}
function getNewestReadings(callback){
  var q = Knex();
  q.select('nodes.id','nodes.sketchname','sensortypes.shortname','R1.real_value','R1.created','R1.sensorindex');
  q.from('readings as R1')
  q.innerJoin('nodes','R1.node','nodes.id');
  q.innerJoin('sensors', function () {
    this.on('R1.sensorindex', '=', 'sensors.sensorindex')
        .andOn('R1.node', '=', 'sensors.node');
  });
  q.innerJoin('sensortypes','sensors.sensortype','sensortypes.id');
  q.whereRaw('"R1".created = (select max(created) from readings where node="R1".node and sensorindex="R1".sensorindex)');
  q.then(function(readings){
    callback(null,readings);
  },function(err){
    log.error("Failed to get latest sensor readings: "+err);
    callback(err);
  });
}
function getBinnedReadings(sensorsToQuery, binUnit, timeFrame, callback){
  sensorsToQuery = _.map(sensorsToQuery, function(sensor){return "'"+sensor+"'";});
  var q = Knex('readings');
  q.select('readings.node','nodes.sketchname', 'sensortypes.longname',
    Knex.raw("date_trunc('"+binUnit+"', readings.created) as bin"),
    Knex.raw("avg(readings.real_value)"));
  q.where('readings.created','>',timeFrame.start);
  q.andWhere('readings.created','<',timeFrame.end);
  q.innerJoin('nodes','readings.node','nodes.id');
  q.innerJoin('sensors','readings.sensorindex','sensors.sensorindex');
  q.innerJoin('sensortypes','sensors.sensortype','sensortypes.id');
  q.groupByRaw("date_trunc('"+binUnit+"', readings.created), readings.node, nodes.sketchname, readings.sensorindex, sensortypes.longname");
  q.havingRaw("readings.node||':'||readings.sensorindex in ("+sensorsToQuery.join()+")");
  q.orderByRaw("date_trunc('"+binUnit+"', readings.created) asc");
  q.then(function(readings){
    callback(null, readings);
  },function(err){
    log.error("Failed to get binned  sensor readings: "+err);
    callback(err);
  });
}
exports.saveProtocol = saveProtocol;
exports.saveSensor = saveSensor;
exports.saveValue = saveValue;
exports.saveBatteryLevel = saveBatteryLevel;
exports.saveSketchName = saveSketchName;
exports.saveSketchVersion = saveSketchVersion;
exports.saveRebootRequest = saveRebootRequest;
exports.checkRebootRequest = checkRebootRequest;
exports.sendNextAvailableSensorId = sendNextAvailableSensorId;
exports.getAllSensors = getAllSensors;
exports.getNewestReadings = getNewestReadings;
exports.getBinnedReadings = getBinnedReadings;
