define [
  'jquery'
  'underscore'
],
($,_)->
  (appliance, size)->
    templateUrl: '/html/modals/cameraModal.html'
    controller: ($scope, $modalInstance, camera)->

      $scope.camera = camera
      $scope.timestamp = new Date().getTime()
      $scope.isMoving = false
      $scope.modalOpen = true

      cameraCmds =
        down:
          start: 0
          end: 1
        up:
          start: 2
          end: 3
        left:
          start: 4
          end: 5
        right:
          start: 6
          end: 7

      keyToDirection = (event)->
        switch event.keyCode
          when 38 then "up"
          when 40 then "down"
          when 37 then "left"
          when 39 then "right"
      invertDirection = (direction)->
        switch direction
            when "left" then return "right"
            when "right" then return "left"
            when "up" then return "down"
            when "down" then return "up"

      $scope.toggleCameraMove = (direction)->
        if $scope.camera.inverted then direction = invertDirection(direction)

        if $scope.isMoving
          $scope.cameraCmd(cameraCmds[direction].end)
        else
          $scope.cameraCmd(cameraCmds[direction].start)

        $scope.isMoving = !$scope.isMoving

      $scope.startCameraMove = (event)->
        direction = keyToDirection(event)
        if $scope.camera.inverted then direction = invertDirection(direction)

        unless $scope.isMoving
          $scope.cameraCmd(cameraCmds[direction].start)
          $scope.isMoving = !$scope.isMoving

      $scope.endCameraMove = (event)->
        direction = keyToDirection(event)
        if $scope.inverted then direction = invertDirection(direction)

        if $scope.isMoving
          $scope.cameraCmd(cameraCmds[direction].end)
          $scope.isMoving = !$scope.isMoving

      $scope.cameraCmd = (command)->
        $.ajax({
          url: "#{$scope.camera.proto}#{$scope.camera.controlUrl}#{$scope.camera.control}"
          data:
            command: command
            token: $scope.camera.token
        }).done ->
          null


      $scope.close = ->
        $scope.modalOpen = false
        $modalInstance.close null

      $scope.cancel = ->
        $modalInstance.dismiss('cancel')
    size: size
    resolve:
      camera: -> appliance
