_ = require "underscore"
amqp = require 'amqp'
rules_db = require "./rules_db"
log = require "winston"
async = require 'async'


#connect to the amqp broker
connectToBroker= (callback)->
  parser = new require('inireader').IniReader()
  parser.load '../config/site.ini'
  rabbitmqUsername = parser.param 'rabbitmq.username'
  rabbitmqPassword = parser.param 'rabbitmq.password'
  rabbitmqHost = parser.param 'rabbitmq.host'
  connection = amqp.createConnection
    url: "amqp://#{rabbitmqUsername}:#{rabbitmqPassword}@#{rabbitmqHost}:5672"
  connection.addListener 'ready', ->
    log.info "successfully connected to amqp broker"
    async.waterfall [
      (callback)->
        callback null, connection
      setupBindings
      setupSubscriptions
    ],(err,bindings)->
      if err
        log.error err
      else
        log.info "completed binding and subscribing to broker"
        callback null,bindings

setupSubscriptions = (bindings, callback)->
  bindings['rules']['commandQueue'].subscribe (message, headers, deliveryInfo, messageObject)->
    message = JSON.parse message.data.toString()
    if message.cmd
      log.info "Received command: #{message.cmd}"
    if message.cmd == "list_rules"
      rules_db.getRules (err, rules)->
        if err
          console.error "Unable to retrieve rules: #{err}"
        else
          bindings['connection'].publish deliveryInfo.replyTo, rules

    else if message.cmd == "get_rule"
      rules_db.getRule message.ruleId, (err, rule)->
        if err
          log.error "Unable to retrieve rules: #{err}"
        else
          bindings['connection'].publish deliveryInfo.replyTo, rule

    else if message.cmd == "delete_rule"
      rules_db.deleteRule message.ruleId, (err, rule)->
        if err
          log.error "Unable to delete rule: #{err}"
        else
          bindings['connection'].publish deliveryInfo.replyTo,{}

    else if message.cmd == "create_rule"
      rules_db.createRule (err, newRule)->
        if err
          log.error "Unable to create new rule: #{err}"
        else
          fanoutExchange.publish "", newRule
          bindings['connection'].publish deliveryInfo.replyTo, {}

    else if message.cmd == "update_rule_name"
      rules_db.updateRuleName message.ruleId, message.name, (err, rule)->
        if err
          log.error "Unable to update rule name: #{err}"
        else
          bindings['connection'].publish deliveryInfo.replyTo, {}

    else if message.cmd == "update_rule_active"
      rules_db.updateRuleActive message.ruleId, message.active, (err, rule)->
        if err
          log.error "Unable to update rule active/inactive: #{err}"
        else
          bindings['connection'].publish deliveryInfo.replyTo, {}

    else if message.cmd == "update_rule_data"
      rules_db.updateRuleData message.ruleId, message.data, (err, rule)->
        if err
          log.error "Unable to update rule data: #{err}"
        else
          bindings['connection'].publish deliveryInfo.replyTo, {}
    else
      log.info "Unrecognized message: #{message}"
  callback null, bindings

setupBinding = (connection, name, bindCmdQueue, bindings, callback)->
  async.waterfall [
    (callback)->
      callback null, bindings
    (bindings, callback)->
      connection.exchange "#{name}.status", {type: "fanout", durable: true, autoDelete: false}, (fanoutExchange)->
        log.info "bound to exchange #{name}.status successfully"
        bindings[name]= {statusExchange: fanoutExchange}
        callback null, bindings
    (bindings, callback)->
      if bindCmdQueue
        connection.queue "#{name}.cmd", (q)->
          log.info "bound to queue #{name}.cmd successfully"
          bindings[name]['commandQueue'] = q
          callback null, bindings
      else
        callback null, bindings
    (bindings, callback)->
      connection.exchange "#{name}.cmd", {type: "direct", durable: true, autoDelete: false}, (directExchange)->
        log.info "bound to exchange #{name}.cmd successfully"
        bindings[name]['commandExchange'] = directExchange
        callback null, bindings
    (bindings, callback)->
      if bindCmdQueue
        bindings[name]['commandQueue'].bind bindings[name]['commandExchange'], '', ->
          log.info "bound #{name} command queue to command exchange successfully"
          callback null, bindings
      else
        callback null, bindings
  ],(err,bindings)->
    if err
      callback err
    else
      callback null, bindings

setupBindings = (connection, callback)->
  async.waterfall [
    (callback)->
      callback null, {connection: connection}
    _.bind setupBinding, @, connection, "rules", true
    _.bind setupBinding, @, connection, "mysensors", false
    _.bind setupBinding, @, connection, "wemo", false
    _.bind setupBinding, @, connection, "nest", false
    _.bind setupBinding, @, connection, "garage", false
    _.bind setupBinding, @, connection, "actiontec", false
    _.bind setupBinding, @, connection, "eyezon", false
  ],(err,bindings)->
    if err
      callback err
    else
      callback null, bindings

exports.connectToBroker = connectToBroker
