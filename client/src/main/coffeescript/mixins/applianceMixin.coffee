define [
  'underscore'
  'util/_deep'
],
(_)->
    ($scope) ->

      #used to apply class-based decorators to the appliance's wrapper
      $scope.getOuterClass= ->
        if $scope.outerClassMap?
          for value, test of $scope.outerClassMap
            if _.isFunction(test) && test() then return value
        return ""

      #determines the position of the appliance on the screen
      $scope.getOuterStyle = ->
        style = {}
        if $scope.appliance?
          unless _.isUndefined(_.deep($scope.appliance, 'location.left'))
            style["left"] = "#{$scope.appliance.location.left}%"
          unless _.isUndefined(_.deep($scope.appliance, 'location.top'))
            style["top"]= "#{$scope.appliance.location.top}%"
          unless _.isUndefined(_.deep($scope.appliance, 'location.rotation'))
            style["-webkit-transform"]= "rotate(#{$scope.appliance.location.rotation}deg)"
          unless _.isUndefined(_.deep($scope.appliance, 'dimensions.width'))
            style["width"]= "#{$scope.appliance.dimensions.width}%"
          unless _.isUndefined(_.deep($scope.appliance, 'dimensions.height'))
            style["height"]= "#{$scope.appliance.dimensions.height}%"
        return style

      #used to render the appliance itself and apply any class-based decorators
      $scope.getInnerClass = ->
        if $scope.innerClassMap?
          for value, test of $scope.innerClassMap
            if _.isFunction(test) && test() then return value

        return ""

      #apply any explicit styles to the appliance itself
      $scope.getInnerStyle = ->
        if $scope.innerStyle?
          $scope.innerStyle
        else
          ""

      #gets a tooltip label if defined
      $scope.getTooltip= ->
        if _.isFunction $scope._getTooltip
          return $scope._getTooltip()
        else
          return ""

      #gets a tooltip label if defined
      $scope.getDisplayLabel= ->
        if _.isFunction $scope._getDisplayLabel
          return $scope._getDisplayLabel()
        else
          return ""


      $scope.click = (appliance)-> if _.isFunction($scope._click) then $scope._click appliance


