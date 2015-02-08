Knex = require('./db').Knex
log = require "winston"
_ = require "underscore"
moment = require "moment"

createNodeBySketchnameIfMissing = (sketchname,type,callback)->
  q = Knex 'nodes'
  q.select 'id'
  .where 'sketchname', '=', sketchname
  .andWhere 'type', '=', type
  .then (results)->
    if results.length == 0
      log.info "Node not found, creating node with sketchname #{sketchname}"
      q.returning 'id'
      q.insert
        sketchname: sketchname
        type: type
      .then (results)-> callback null, results[0]
    else
      callback null, results[0].id
createNodeIfMissing= (id,callback)->
  q = Knex 'nodes'
  q.count 'id'
  .where 'id', '=', id
  .then (result)->
    if parseInt(result[0].count) == 0
      log.info "Node not found, creating node with id #{id}"
      q.insert
        id: id
      .then -> callback null
    else
      log.info "Node with id of #{id} already exists"
      callback null

saveProtocol = (sender, payload, callback)->
  if isNaN parseFloat(sender) then callback "protocol is nan, can't save"
  else
    createNodeIfMissing sender, ->
      q = Knex 'nodes'
      q.where 'id', '=', sender
      .update 'protocol', payload
      .then ->
        log.info "Finished updating node #{sender} protocol to #{payload}"
        callback null
      ,(err)->
        log.error "Failed to update node #{sender} protocol to #{payload}: #{err}"
        callback err


saveSensor = (sender, sensor, type,callback)->
  createNodeIfMissing sender, ->
    q = Knex 'sensors'
    q.select 'sensortype', 'sensorindex'
    .where 'node', '=', sender
    .then (sensors)->
      existingSensor = _.findWhere sensors, {sensorindex: sensor}
      if existingSensor? and existingSensor.sensorType != type
        log.info "node #{sender} already defined a sensor at index #{sensor}, skipping"
        callback null
      else if existingSensor?
        log.warn "node #{sender} already defined a sensor at index #{sensor} of a different type"
        callback "node sensor exisits with a different type"
      else
        q.insert
          node: sender
          sensortype: type
          sensorindex: sensor
        .then ->
          log.info "Inserted a new sensor for #{sender} indexed as #{sensor} a #{type}"
          callback null
        ,(err)->
          log.error "Failed to insert a new sensor for #{sender} indexed as #{sensor} a #{type}: #{err}"
          callback err

saveValue = (sender, sensor, type, payload,callback)->
    record =
      node:sender
      sensorindex: sensor
      real_value: parseFloat payload


    q = Knex 'readings'
    q.insert record
    .then ->
      log.info "Inserted #{payload} into node #{sender}'s sensor #{sensor}"
      if callback? then callback null, record
    ,(err)->
      log.error "Failed to insert #{payload} into node #{sender}'s sensor #{sensor}: #{err}"
      if callback? then callback err

saveBatteryLevel = (sender, payload, db,callback)->
  # var cn = "BatteryLevel-" + sender.toString();
  # db.createCollection(cn, function(err, c) {
  #   c.save({
  #     'timestamp': new Date().getTime(),
  #     'value': payload
  #   }, function(err, result) {
  #     if (err)
  #       log.error("Error writing battery level to database");
  #   });
  # });
  log.warn "mysensors_db::saveBatteryLevel not implemented"
  callback null

saveSketchName = (sender, payload,callback)->
  createNodeIfMissing sender, ->
    q = Knex 'nodes'
    q.where 'id', '=', sender
    .update 'sketchname', payload
    .then ->
      log.info "Saved sketch name for #{sender}"
      callback null
    ,(err)->
      log.error "Failed to save sketch name for #{sender}: #{err}"
      callback err


saveSketchVersion = (sender, payload,callback)->
  createNodeIfMissing sender, ->
    q = Knex 'nodes'
    q.where 'id', '=', sender
    .update 'sketchversion', payload
    .then ->
      log.info "Saved sketch version for #{sender}"
      callback null
    ,(err)->
      log.error "Failed to save sketch version for #{sender}"
      callback err

saveRebootRequest =(destination, db,callback)->
  # db.collection('node', function(err, c) {
  #   c.update({
  #     'id': destination
  #   }, {
  #     $set: {
  #       'reboot': 1
  #     }
  #   }, function(err, result) {
  #     if (err)
  #       log.error("Error writing reboot request to database");
  #   });
  # });
  log.warn "mysensors_db::saveRebootRequest not implemented"
  callback null

checkRebootRequest = (destination, db, gw,callback)->
  # db.collection('node', function(err, c) {
  #   c.find({
  #     'id': destination
  #   }, function(err, item) {
  #     if (err)
  #       log.error('Error checking reboot request');
  #     else if (item.reboot == 1)
  #       sendRebootMessage(destination, gw);
  #   });
  # });
  log.warn "mysensors_db::checkRebootRequest not implemented"
  callback null

sendNextAvailableSensorId = (callback)->
  q = Knex 'nodes'
  .first Knex.raw('max(id) as maxid')
  .then (result)->
    nextId = parseInt(result.maxid,10) + 1
    log.info "mysensors_db::sendNextAvailableSensorId inserting new node with id #{nextId}"
    q = Knex 'nodes'
    .insert
      id: nextId
      protocol: null
      sketchname: null
      sketchversion: null
    .then ->
      callback null, nextId
    , (err)->
      log.error "Failed to create new sensor: #{err}"
      callback err

getAllSensors = (callback)->
  q = Knex 'sensors'
  q.select 'nodes.sketchname','sensors.node','sensors.sensorindex','sensortypes.longname'
  .innerJoin 'sensortypes','sensors.sensortype','sensortypes.id'
  .innerJoin 'nodes','sensors.node','nodes.id'
  .then (sensors)->
    callback null,sensors
  , (err)->
    log.error "Failed to get list of available sensors: #{err}"
    callback err

getNewestReadingsForType = (sensor_types, node_types, callback)-> _getNewestReadings sensor_types,node_types,callback
getNewestReadings = (sensor_types, callback)-> _getNewestReadings sensor_types, null, callback

_getNewestReadings = (sensor_types, node_types, callback)->

  q = Knex()
  q.select 'nodes.id', 'nodes.sketchname', 'sensortypes.shortname', 'readings.real_value', 'readings.created', 'readings.sensorindex', 'sensors.extra'
  .from "readings"
  .innerJoin 'nodes','readings.node','nodes.id'
  .innerJoin 'sensors', ->
    @on 'readings.sensorindex', '=', 'sensors.sensorindex'
    .andOn 'readings.node', '=', 'sensors.node'

  .innerJoin 'sensortypes','sensors.sensortype','sensortypes.id'
  if sensor_types?
    q.whereIn 'sensors.sensortype', sensor_types
  if node_types?
    q.whereIn 'nodes.type', node_types
  q.whereRaw "readings.created between TIMESTAMPTZ '#{moment.utc().subtract(7, 'days').format()}' and '#{moment.utc().format()}'"
  .joinRaw "inner join (select node, sensorindex, MAX(created) as max_created from readings WHERE created between TIMESTAMPTZ '#{moment.utc().subtract(7, 'days').format()}' and '#{moment.utc().format()}' group by node,sensorindex ) latest on readings.node = latest.node and readings.sensorindex = latest.sensorindex and readings.created = latest.max_created"
  q.then (readings)->
    callback null,readings
  ,(err)->
    log.error "Failed to get latest sensor readings: #{err}"
    callback err
getNewestReadingBySensorindex = (node, sensorindex, callback)->
  q = Knex()
  q.first 'readings.real_value'
  .from 'readings'
  .where 'node', '=', node
  .andWhere 'sensorindex', '=', sensorindex
  .orderBy 'created', 'desc'
  .then (reading)->
    callback null, reading
  , (err)->
    log.error "Failed to get newest sensor reading: #{err}"
    callback err

getBinnedReadings = (sensorsToQuery, binUnit, timeFrame, callback)->
  sensorsToQuery = _.map sensorsToQuery, (sensor)-> "'#{sensor}'"
  q = Knex 'readings'
  q.select 'readings.node','nodes.sketchname', 'sensortypes.longname',
    Knex.raw("date_trunc('#{binUnit}', readings.created) as bin"),
    Knex.raw("avg(readings.real_value)")
  .whereBetween 'readings.created',[timeFrame.start,timeFrame.end]
  .innerJoin 'nodes','readings.node','nodes.id'
  .innerJoin 'sensors','readings.sensorindex','sensors.sensorindex'
  .innerJoin 'sensortypes','sensors.sensortype','sensortypes.id'
  .groupByRaw "date_trunc('#{binUnit}', readings.created), readings.node, nodes.sketchname, readings.sensorindex, sensortypes.longname"
  .havingRaw "readings.node||':'||readings.sensorindex in (#{sensorsToQuery.join()})"
  .orderByRaw "date_trunc('#{binUnit}', readings.created) asc"
  .then (readings)->
    callback null, readings
  , (err)->
    log.error "Failed to get binned  sensor readings: #{err}"
    callback err

exports.createNodeBySketchnameIfMissing = createNodeBySketchnameIfMissing
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
exports.getNewestReadingBySensorindex = getNewestReadingBySensorindex;
exports.getNewestReadingsForType = getNewestReadingsForType;
exports.getNewestReadings = getNewestReadings;
exports.getBinnedReadings = getBinnedReadings;
