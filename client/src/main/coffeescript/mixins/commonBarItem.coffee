define [
  'underscore'
],
(_)->
    ($scope, $timeout) ->
      $scope.clicked = false

      $scope.getInputClass= ->
        "input#{$scope.recipe.recipeId}"

      $scope._update= ->
        logic = ->
          unless _.contains $(".#{$scope.getInputClass()}"), document.activeElement
            $scope.clicked = false
            $scope.update()
        $timeout logic, 10


