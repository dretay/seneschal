var Knex = require('./db').Knex;
var log = require("winston");
var _ = require("underscore");

function createRule(callback){
  var q = Knex('rules');
  q.returning('id');
  q.insert({
    name: "New Rule"
  });
  q.then(function(ids){
    callback(null, {id: ids[0], name:"New Rule",active: true});
  },function(err){
    log.error("Failed to insert new rule: "+err);
    callback(err);
  });
}
function deleteRule(id, callback){
  var q = Knex('rules');
  q.where('id','=',id);
  q.del();
  q.then(function(){
    callback(null);
  },function(err){
    log.error("Failed to delete rule "+id+": "+err);
    callback(err);
  });
}
function updateRuleActive(id, active, callback){
  var q = Knex('rules');
  q.where('id','=',id);
  q.update({
    active: active
  });
  q.then(function(){
    callback(null);
  },function(err){
    log.error("Failed to update rule "+id+"'s active / inactive: "+err);
    callback(err);
  });
}
function updateRuleName(id, name, callback){
  var q = Knex('rules');
  q.where('id','=',id);
  q.update({
    name: name
  });
  q.then(function(){
    callback(null);
  },function(err){
    log.error("Failed to update rule "+id+"'s name: "+err);
    callback(err);
  });
}
function updateRuleData(id, json, xml, callback){
  var q = Knex('rules');
  q.where('id','=',id);
  q.update({
    data_json: json,
    data_xml: xml
  });
  q.then(function(){
    callback(null);
  },function(err){
    log.error("Failed to update rule "+id+"'s data: "+err);
    callback(err);
  });
}
function getRule(id, callback){
  var q = Knex();
  q.first('data_xml', 'data_json');
  q.from('rules')
  q.where('id','=',id);
  q.then(function(rule){
    callback(null,rule);
  },function(err){
    log.error("Failed to get rule "+id+": "+err);
    callback(err);
  });
}
function getRules(callback){
  var q = Knex();
  q.select('id','name','active','created');
  q.from('rules')
  q.then(function(rules){
    callback(null,rules);
  },function(err){
    log.error("Failed to get list of system rules: "+err);
    callback(err);
  });
}
exports.createRule = createRule;
exports.deleteRule = deleteRule;
exports.updateRuleActive = updateRuleActive;
exports.updateRuleName = updateRuleName;
exports.updateRuleData = updateRuleData;
exports.getRules = getRules;
exports.getRule = getRule;