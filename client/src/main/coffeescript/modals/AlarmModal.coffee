define [
    'jquery'
    'underscore'
    's/alarmKeypads'
    'p/webStomp'
    'd/focusMe'
  ],
($, _)->
  (appliance, size)->
    templateUrl: '/html/modals/keypadModal.html'
    controller: ($scope, $modalInstance, alarmKeypads, webStomp, defaultKeypad)->
      this.alarmKeypads = alarmKeypads

      #TODO: this should be part of some over-arching mechanic...
      $scope.$on '$destroy', ->
        webStomp.client.unsubscribe alarmKeypads.subscriptionHandler.id

      $scope.defaultKeypad = defaultKeypad
      $scope.keypads = alarmKeypads.query()
      $scope.modalOpen = true
      $scope.form =
        commands:
          away: false
          stay: false
          instant: true
        passcode: ""

      $scope.getKeypad = ->
        if $scope.keypads.length > 0
          $scope.keypads[0]
        else
          $scope.defaultKeypad
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

