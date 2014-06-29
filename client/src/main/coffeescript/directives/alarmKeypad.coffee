define [
  'd/directives'
  'jquery'
  'underscore'
  's/alarmKeypads'
  'p/webStomp'
  'd/focusMe'
],
(directives, $, _) ->
  'use strict'

  directives.directive 'alarmKeypad', ->
    restrict: 'E'
    replace: false
    templateUrl: '/html/directives/alarmKeypad.html'
    scope:
      keypad: "="

    controller: ($scope, $injector, $timeout, $modal, $log, webStomp)->

      $scope.openKeypad= (size)->
        modalInstance = $modal.open
          templateUrl: '/html/modals/keypadModal.html'
          controller: ($scope, $modalInstance, alarmKeypads, webStomp, defaultKeypad)->
            this.alarmKeypads = alarmKeypads

            #TODO: this should be part of some over-arching mechanic...
            $scope.$on '$destroy', -> webStomp.client.unsubscribe alarmKeypads.subscriptionHandler.id

            $scope.defaultKeypad = defaultKeypad
            $scope.keypads = alarmKeypads.query()
            $scope.modalOpen = true
            $scope.form=
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
                command = _.find (for command, value of $scope.form.commands then if value then command), (cmd)-> !_.isUndefined cmd
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
            defaultKeypad: -> $scope.keypad


        modalInstance.result.then (command)->
            webStomp.client.send "/amq/queue/eyezon.alarm",null, command
        ,->
          $log.info('Modal dismissed at: ' + new Date());

      $scope.getClass= -> ""

      $scope.getStyle = ->
        "left": "#{$scope.keypad.location.left}%"
        "top": "#{$scope.keypad.location.top}%"
      $scope.isArmed = (keypad)->
        leds = keypad.data.leds
        (leds['ARMED STAY'] || leds['ARMED (ZERO ENTRY DELAY)'] || leds['ARMED AWAY'])

      $scope.update = (name)->
          $scope.light.status = !$scope.light.status
          $scope.pending = true
          $scope.light.update().then ->
            $scope.pending = false
      null