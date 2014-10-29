Knex = require("./db").Knex;
log = require "winston"
_ = require "underscore"

createRule = (callback)->
  q = Knex 'rules'
  q.returning 'id'
  q.insert
    name: "New Rule"

  q.then (ids)->
    callback null,
      id: ids[0]
      name:"New Rule"
      active: true
  , (err)->
    log.error "Failed to insert new rule: #{err}"
    callback err


deleteRule = (id, callback)->
  q = Knex 'rules'
  q.where 'id', '=', id
  q.del();
  q.then ->
    callback null
  , (err)->
    log.error "Failed to delete rule #{id}: #{err}"
    callback err

toggleRuleActive = (id, callback)->
  q = Knex.raw("update rules SET active = NOT active where id = ?", id)
  q.then ->
    callback null
  , (err)->
    log.error "Failed to toggle rule #{id}'s active / inactive: #{err}"
    callback err

updateRuleName = (id, name, callback)->
  q = Knex 'rules'
  q.where 'id', '=', id
  q.update
    name: name
  q.then ->
    callback null
  , (err)->
    log.error "Failed to update rule #{id}'s name: #{err}"
    callback err

updateRuleData = (id, data,callback)->
  q = Knex 'rules'
  q.where 'id', '=', id
  q.update
    data: data
  q.then ->
    callback null
  , (err)->
    log.error "Failed to update rule #{id}'s data: #{err}"
    callback err

getRule = (id, callback)->
  q = Knex()
  q.first 'data'
  q.from 'rules'
  q.where 'id', '=', id
  q.then (rule)->
    callback null,rule
  , (err)->
    log.error "Failed to get rule #{id}: #{err}"
    callback err

getRules = (callback)->
  q = Knex()
  q.select 'id', 'name', 'active', 'created'
  q.from 'rules'
  q.then (rules)->
    callback null,rules
  , (err)->
    log.error "Failed to get list of system rules: #{err}"
    callback err

getAllActiveRuleData = (callback)->
  q = Knex()
  q.select 'id', 'name', 'created', 'data'
  q.from 'rules'
  q.where 'active','=',true
  q.then (rules)->
    callback null,rules
  , (err)->
    log.error "Failed to get list of system rules: #{err}"
    callback err

exports.createRule = createRule
exports.deleteRule = deleteRule
exports.toggleRuleActive = toggleRuleActive
exports.updateRuleName = updateRuleName
exports.updateRuleData = updateRuleData
exports.getAllActiveRuleData = getAllActiveRuleData
exports.getRules = getRules
exports.getRule = getRule