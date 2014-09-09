define [
    'jquery'
    'underscore'
    's/alarmKeypad'
    'p/webStomp'
    'd/focusMe'
  ],
($, _)->
  (appliance, size)->
    templateUrl: '/html/modals/keypadModal.html'
    controller: ($scope, $modalInstance, alarmKeypad, webStomp, defaultKeypad)->
      this.alarmKeypad = alarmKeypad

      $scope.defaultKeypad = defaultKeypad
      $scope.keypad = alarmKeypad.query(null,{isArray:false, scope:$scope})
      $scope.modalOpen = true
      $scope.form =
        commands:
          away: false
          stay: false
          instant: true
        passcode: ""

      $scope.getKeypad = ->
        if not _.isEmpty $scope.keypad then $scope.keypad else $scope.defaultKeypad
      $scope.ok = ->
        if $scope.getKeypad().data.leds.READY
          command = _.find (for command, value of $scope.form.commands then if value then command), (cmd)->
            !_.isUndefined cmd
          if command == "instant"
            $modalInstance.close "#3"
          else if command == "stay"
            $modalInstance.close "#{$scope.form.passcode}3"
          else
            $modalInstance.close "#{$scope.form.passcode}2"
        else
          $modalInstance.close "#{$scope.form.passcode}1"

      $scope.cancel = ->
        $scope.modalOpen = false
        $modalInstance.dismiss('cancel')
    size: size
    resolve:
      defaultKeypad: ->
        appliance

