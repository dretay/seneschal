define [
    'underscore'
    'ejs/templates'
    'util/_deep'
    'd/onLongPress'
    'd/ngRightClick'
    'f/prettyFloorName'
    'f/prettyTypeName'
    'f/capitalize'
    'jqueryPxEm'
  ],
(_,templates)->
  ($scope, $modal, $timeout) ->

    #stolen from http://stackoverflow.com/questions/16297238/angularjs-different-views-based-on-desktop-or-mobile
    isMobile = `(function() {
      var check = false;
      (function(a){if(/(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows (ce|phone)|xda|xiino/i.test(a)||/1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(a.substr(0,4)))check = true})(navigator.userAgent||navigator.vendor||window.opera);
        return check;
    })();`

    $scope.itemOnLongPress = -> $scope.dragEnabled = true

    $scope.dragEnabled = false

    $scope.onApplianceDragStop = (event, ui)->

      # wait to allow the regular click handler to fire before disabling drag
      $timeout ->
        $scope.dragEnabled = false
      ,100

      $scope.appliance.update
        operation: "updateSensorMetadata"
        node_id: $scope.appliance.node_id
        sensor_id: $scope.appliance.sensor_id
        metadata:
          location: _.extend $scope.appliance.location,
            left: (ui.position.left / $('body').width()) * 100
            top: (ui.position.top / ($('body').height())) * 94.5 # todo - where are those 13px coming from!??



    $scope.getName=-> $scope.appliance.name
    $scope.getApplianceClass= ->
      if isMobile then "applianceMobile" else "appliance"
    outerClassLookupTable=
      lamp: ($scope)->
        "applianceLoading": -> $scope.pending
        "lamp-on": -> $scope.appliance.status == true
        "lamp-off": -> $scope.appliance.status == false
      light: ($scope)->
        "applianceLoading": -> $scope.pending
        "lightbulb-on": -> $scope.appliance.status == true
        "lightbulb-off": -> $scope.appliance.status == false
      floodLight: ($scope)->
        "applianceLoading": -> $scope.pending
        "floodLight-on": -> $scope.appliance.status == true
        "floodLight-off": -> $scope.appliance.status == false
      "threedprinter": ($scope)->
        "applianceLoading": -> $scope.pending
        "threedprinter-on": -> $scope.appliance.status == true
        "threedprinter-off": -> $scope.appliance.status == false
      christmastree: ($scope)->
        "applianceLoading": -> $scope.pending
        "christmastree-on": -> $scope.appliance.status == true
        "christmastree-off": -> $scope.appliance.status == false
      fan: ($scope)->
        "applianceLoading": -> $scope.pending
        "fan fa fa-spin": -> $scope.appliance.status == true
        "fan": -> $scope.appliance.status == false
      dehumidifier: ($scope)->
        "applianceLoading": -> $scope.pending
        "dehumidifier-on": -> $scope.appliance.status == true
        "dehumidifier-off": -> $scope.appliance.status == false
      monitor: ($scope)->
        "applianceLoading": -> $scope.pending
        "monitor-on": -> $scope.appliance.status == true
        "monitor-off": -> $scope.appliance.status == false
      keypad: ($scope)->
        "fa fa-lock fa-stack-1x text-danger": ->$scope.isArmed()
        "fa fa-lock fa-stack-1x text-success": ->!$scope.isArmed()
      doorZone: ($scope)->
        "door-open": -> $scope.appliance.open && isMobile
        "door-recent-close": -> $scope.delta.asHours() < 1 && isMobile
        "door-closed": -> isMobile
        "progress-bar progress-bar-danger alarmZone": -> $scope.appliance.open
        "progress-bar progress-bar-success alarmZone": -> $scope.delta.asHours() > 1
        "progress-bar progress-bar-warning alarmZone": -> true




    #used to apply class-based decorators to the appliance's wrapper
    $scope.getOuterClass = ->
      if $scope.appliance?
        outerClassMap = null
        if $scope.outerClassMap?
          outerClassMap = $scope.outerClassMap
        else if _.isFunction outerClassLookupTable[$scope.appliance.type]
          outerClassMap = outerClassLookupTable[$scope.appliance.type]($scope)
        if not _.isNull outerClassMap
          for value, test of outerClassMap
            if _.isFunction(test) && test()
              if $scope.dragEnabled then return "shake shake-constant #{value}" else return value
        else if $scope.dragEnabled then return "shake shake-constant"

      return ""

    #determines the position of the appliance on the screen
    $scope.getOuterStyle = ->
      style = {}
      if $scope.appliance? and not isMobile
        unless _.isUndefined(_.deep($scope.appliance, 'location.left'))
          style["left"] = "calc(#{$scope.appliance.location.left}vw)"
        unless _.isUndefined(_.deep($scope.appliance, 'location.top'))
          style["top"] = "calc(#{$scope.appliance.location.top}vh)"
        unless _.isUndefined(_.deep($scope.appliance, 'location.rotation'))
          style["-webkit-transform"] = "rotate(#{$scope.appliance.location.rotation}deg)"
        unless _.isUndefined(_.deep($scope.appliance, 'location.padding_top'))
          style["padding-top"] = "#{$scope.appliance.location.padding_top}"
        unless _.isUndefined(_.deep($scope.appliance, 'dimensions.width'))
          style["width"] = "#{$scope.appliance.dimensions.width}"
        unless _.isUndefined(_.deep($scope.appliance, 'dimensions.height'))
          style["height"] = "#{$scope.appliance.dimensions.height}"
        unless _.isUndefined(_.deep($scope.appliance, 'dimensions.padding'))
          style["padding"] = "#{$scope.appliance.dimensions.padding}"
      if $scope._getOuterStyle?
        return _.extend $scope._getOuterStyle(), style
      else
        return style

    #used to render the appliance itself and apply any class-based decorators
    $scope.getInnerClass = ->
      if $scope.innerClassMap?
        for value, test of $scope.innerClassMap
          if _.isFunction(test) && test() then return value

      return ""

    #apply any explicit styles to the appliance itself
    $scope.getInnerStyle = ->
      if $scope._getInnerStyle?
        $scope._getInnerStyle()
      else
        ""

    #gets a tooltip label if defined
    $scope.getTooltip = ->
      if _.isFunction $scope._getTooltip
        return $scope._getTooltip()
      else
        return ""

    #gets a tooltip label if defined
    $scope.getDisplayLabel = ->
      if _.isFunction $scope._getDisplayLabel
        return $scope._getDisplayLabel()
      else
        return ""


    $scope.floors = [ 'basement', 'mainFloor', 'secondFloor']
    $scope.types = ['lamp','light','floodLight','christmastree','fan', 'dehumidifier','monitor','keypad','doorZone']

    $scope.editExtra = ->
      $modal.open

        template: templates['applianceModal']
        controller: ($scope,$modalInstance)->

          $scope.ok = ->
            $scope.appliance.update
              operation: "updateSensorMetadata"
              node_id: $scope.appliance.node_id
              sensor_id: $scope.appliance.sensor_id
              metadata:
                floor: $scope.appliance.floor
                type: $scope.appliance.type
                location: $scope.appliance.location
            # should call save here and update the backend json
            $modalInstance.close $scope.appliance
            null
          $scope.cancel = ->
            $modalInstance.dismiss('cancel')

        size: 'lg'
        scope: $scope
    $scope.click = (appliance)->
      if _.isFunction($scope._click) and not $scope.dragEnabled then $scope._click appliance


