rules_db = require "./rules_db"
_ = require "underscore"
log = require "winston"
coffee = require 'coffee-script'
rabbitmq = require "./rabbitmq"
async = require 'async'

subscriptions = []
executeActiveRules = (amqpConnection, bindings, callback)->
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
        else
          log.info "Skipping rule #{rule.name}"
        async.parallel ruleList, (err,results)->
          for result in results
            if _.isArray result
              subscriptions.concat result
            else if _.isObject result
              subscriptions.push result
          callback null, null

reloadRules = (callback)->
  for subscription in subscriptions
    subscription.queue.unsubscribe subscription.id
  executeActiveRules null,null, callback

exports.executeActiveRules = executeActiveRules
exports.reloadRules = reloadRules