define [
    'jquery'
    'underscore'
    'ejs/templates'
    's/rules'

  ],
($, _, templates)->
  (ruleName, ruleId, size)->
    template: templates['ruleModal']
    controller: ($scope, $modalInstance, rules, ruleName, ruleId)->
      $scope.ruleName = ruleName
      $scope.ruleId = ruleId

      $scope.rule = rules.query({ruleId: ruleId},{isArray:false, scope:$scope})

      $scope.$watch 'rule', (rule)->
        unless _.isEmpty rule
          if _.isString(rule.data_xml) and rule.data_xml.length > 0
            loadData = ->
              if Blockly?
                Blockly.Xml.domToWorkspace(Blockly.mainWorkspace,Blockly.Xml.textToDom(rule.data_xml))
              else
                setTimeout loadData, 100
            setTimeout loadData, 100
      , true

      $scope.save = ->

        $scope.rule.update
          ruleId: $scope.ruleId
          json: JSON.stringify Blockly.JavaScript.workspaceToCode()
          xml: Blockly.Xml.domToText(Blockly.Xml.workspaceToDom(Blockly.mainWorkspace))
        $modalInstance.close()

      $scope.cancel = ->
        $scope.modalOpen = false
        $modalInstance.dismiss('cancel')
    size: size
    resolve:
      ruleName: -> ruleName
      ruleId: -> ruleId


