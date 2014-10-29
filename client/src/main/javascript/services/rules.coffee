define [
    'angular'
    's/services'
    'underscore'
    'r/WebStompResource'

  ],
(angular, services, _) ->
  'use strict'

  services.factory 'rules', ['webStompResource', (Resource)->
    new Resource
      get:
        subscription: "/exchange/rules.status/fanout"
        outbound_rpc: "/exchange/rules.cmd"
        outboundTransform: (rawData)->
          if rawData.ruleId?
            cmd: "get_rule"
            ruleId: rawData.ruleId
          else
            cmd: "list_rules"
        inboundTransform: (rawData,oldData)->
          if _.isArray rawData
            return rawData
          else if _.isObject(rawData) and _.isArray(oldData)
            oldData.push rawData
            return oldData
          else
            if _.isString(rawData.data) and rawData.data.length > 0
              rawData.data = JSON.parse rawData.data
            return rawData

      save:
        outbound_rpc: "/exchange/rules.cmd"
        outboundTransform: (params, rule)->
          cmd: 'create_rule'
      delete:
        outbound_rpc: "/exchange/rules.cmd"
        outboundTransform: (params, rule)->
          cmd: 'delete_rule'
          ruleId: rule.id
      update:
        outbound_rpc: "/exchange/rules.cmd"
        outboundTransform: (params, rule)->
          if _.isString(params) and params == "name"
            cmd: 'update_rule_name'
            name: rule.name
            ruleId: rule.id
          else if _.isString(params) and params == "active"
            cmd: 'toggle_rule_active'
            ruleId: rule.id
          else
            cmd: 'update_rule_data'
            ruleId: params.ruleId
            data: params.data

  ]