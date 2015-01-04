define [
    'c/controllers'
    'modals/RuleModal'
    's/rules'
    'f/humanizedDuration'
  ],
(controllers, RuleModal) ->
  'use strict'

  controllers.controller 'rules', ['$scope', '$rootScope', 'rules', '$modal', ($scope, $rootScope, rules, $modal)->

    $scope.rules = rules.query(null,{scope:$scope})

    currentEditField = ""
    oldValue = ""
    $scope.currentlyEditing = (id,fieldName)-> "#{id}:#{fieldName}" == currentEditField
    $scope.setEditingField = (id,fieldName,currentValue)->
      currentEditField = "#{id}:#{fieldName}"
      oldValue = currentValue
    $scope.newRule = ->
      rule = rules.create {}
      rule.save()
    $scope.cancelEditing = (index,field)->
      currentEditField = ""
      $scope.rules[index][field] = oldValue
      oldValue = ""
    $scope.deleteRule = (index,rule)->
      $scope.rules.splice index, 1
      rule.delete()
    $scope.toggleActive = (rule)->
      rule.update "active"
    $scope.saveName = (rule)->
      rule.update "name"
      currentEditField = ""


    $scope.editRule = (ruleName, ruleId)->
      $modal.open RuleModal ruleName, ruleId, "lg"


  ]