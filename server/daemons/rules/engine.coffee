rules_db = require "./rules_db"
_ = require "underscore"
log = require "winston"
coffee = require 'coffee-script'

compileRules = (context, callback)->
  rules_db.getAllActiveRuleData (err, rules)->
    if err
      callback err
    else
      for rule in rules
        fn = new Function "context",  coffee.compile(JSON.parse(rule.data), {bare: on})
        fn.call @, context
      callback null

exports.compileRules = compileRules