var _ = require("underscore");
var amqp = require('amqp');
var rules_db = require("./rules_db")
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
  config.amqpConnection.exchange("rules.status",{type: "fanout", durable: true, autoDelete: false}, function(fanoutExchange){
    config.amqpConnection.queue("rules.cmd", function (q) {
      config.amqpConnection.exchange("rules.cmd",{type: "direct", durable: true, autoDelete: false}, function(directExchange){
          q.bind(directExchange, '', function(){
            q.subscribe(function (message, headers, deliveryInfo, messageObject) {
              message = JSON.parse(message.data.toString());
              if(message.cmd){
                log.info("Received command: "+message.cmd);
              }
              if(message.cmd === "list_rules"){
                rules_db.getRules(function(err, rules){
                  if(err){
                    console.error("Unable to retrieve rules: "+err);
                  }else{
                    config.amqpConnection.publish(deliveryInfo.replyTo,rules);
                  }
                });
              }
              else if(message.cmd === "get_rule"){
                rules_db.getRule(message.ruleId, function(err, rule){
                  if(err){
                    log.error("Unable to retrieve rules: "+err);
                  }else{
                    config.amqpConnection.publish(deliveryInfo.replyTo,rule);
                  }
                });
              }
              else if(message.cmd === "delete_rule"){
                rules_db.deleteRule(message.ruleId, function(err, rule){
                  if(err){
                    log.error("Unable to delete rule: "+err);
                  }else{
                    config.amqpConnection.publish(deliveryInfo.replyTo,{});
                  }
                });
              }
              else if(message.cmd === "create_rule"){
                rules_db.createRule(function(err, newRule){
                  if(err){
                    log.error("Unable to create new rule: "+err);
                  }else{
                    fanoutExchange.publish("", newRule);
                    config.amqpConnection.publish(deliveryInfo.replyTo,{});
                  }
                });
              }
              else if(message.cmd === "update_rule_name"){
                rules_db.updateRuleName(message.ruleId, message.name, function(err, rule){
                  if(err){
                    log.error("Unable to update rule name: "+err);
                  }else{
                    config.amqpConnection.publish(deliveryInfo.replyTo,{});
                  }
                });
              }
              else if(message.cmd === "update_rule_active"){
                rules_db.updateRuleActive(message.ruleId, message.active, function(err, rule){
                  if(err){
                    log.error("Unable to update rule active/inactive: "+err);
                  }else{
                    config.amqpConnection.publish(deliveryInfo.replyTo,{});
                  }
                });
              }
              else if(message.cmd === "update_rule_data"){
                rules_db.updateRuleData(message.ruleId, message.json, message.xml, function(err, rule){
                  if(err){
                    log.error("Unable to update rule data: "+err);
                  }else{
                    config.amqpConnection.publish(deliveryInfo.replyTo,{});
                  }
                });
              }else{
                log.info("Unrecognized message: "+message);
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
