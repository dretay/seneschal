rules_db = require "./rules_db"
_ = require "underscore"
log = require "winston"
coffee = require 'coffee-script'
rabbitmq = require "./rabbitmq"
async = require 'async'

amqpConnection = null
bindings = null
executeActiveRules = (amqpConnectionIn, bindingsIn, callback)->
  amqpConnection = amqpConnectionIn
  bindings = bindingsIn
  log.info "Starting dynamic rule execution"
  rules_db.getAllActiveRuleData (err, rules)->
    if err
      callback err
    else if rules? and rules.length > 0
      log.info "Will now execute #{rules.length} rules"
      ruleList = []
      for rule in rules
        if _.isString(rule.data) and rule.data.length > 0
          log.info "Creating rule #{rule.name}"
          ruleJavascript = coffee.compile(JSON.parse(rule.data), {bare: on})
          ruleList.push _.bind (new Function "context", "callback", ruleJavascript), @,
            amqpConnection: amqpConnection
            bindings: bindings
            _: _
        else
          log.info "Skipping rule #{rule.name}"
        async.parallel ruleList, (err,results)->
          callback null, null

reloadRules = (callback)->

  bindings.handlers[key] = [] for key,value of bindings.handlers
  executeActiveRules amqpConnection, bindings, callback

exports.executeActiveRules = executeActiveRules
exports.reloadRules = reloadRules