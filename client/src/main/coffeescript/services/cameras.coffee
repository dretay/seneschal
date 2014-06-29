define [
  'angular'
  's/services'
  'jquery'
],
(angular, services, $) ->
  'use strict'

  #TODO: this will be pulled from redis but temporarily is being hard-coded
  services.factory 'cameras', ['$routeParams', ($routeParams)->
    mediaViewUrl: ->
      "#{@proto}#{@videoUrl}?token=#{encodeURIComponent @token}"
    foscamViewUrl: ->
      "#{@proto}#{@videoUrl}#{@stream}?token=#{encodeURIComponent @token}&rate=3"
    query: ()->
      [{
          name: "Garage"
          status: false
          floor: "mainFloor"
          location:
            left: 62
            top: 47
          rotation: 90
          videoUrl: "www.drewandtrish.com:9000/cameras/192.168.1.28/8081/"
          token: $routeParams.token
          proto: "https://"
          # inverted: true
          viewUrl: @mediaViewUrl

      }

      {
        name: "Porch"
        status: false
        floor: "mainFloor"
        location:
          left: 44
          top: 75
        rotation: 135
        videoUrl: "www.drewandtrish.com:9000/cameras/192.168.1.18/8083"
        controlUrl: "www.drewandtrish.com:9000/cameras/192.168.1.18/8083"
        token: $routeParams.token
        proto: "https://"
        inverted: true
        stream: '/videostream.cgi'
        control: '/decoder_control.cgi'
        viewUrl: @foscamViewUrl
      }
      {
        name: "Front Door"
        status: false
        floor: "mainFloor"
        location:
          left: 36
          top: 67
        rotation: -90
        videoUrl: "www.drewandtrish.com:9000/cameras/192.168.1.17/8080"
        controlUrl: "www.drewandtrish.com:9000/cameras/192.168.1.17/8080"
        token: $routeParams.token
        proto: "https://"
        stream: '/videostream.cgi'
        control: '/decoder_control.cgi'
        viewUrl: @foscamViewUrl
      }
      {
        name: "Living Room"
        status: false
        floor: "mainFloor"
        location:
          left: 47.5
          top: 13
        rotation: 90
        videoUrl: "www.drewandtrish.com:9000/cameras/192.168.1.16/8082"
        controlUrl: "www.drewandtrish.com:9000/cameras/192.168.1.16/8082"
        token: $routeParams.token
        proto: "https://"
        stream: '/videostream.cgi'
        control: '/decoder_control.cgi'
        viewUrl: @foscamViewUrl
      }
      {
        name: "Walk Out"
        status: false
        floor: "basement"
        location:
          left: 37
          top: 13
        rotation: 45
        videoUrl: "www.drewandtrish.com:9000/cameras/192.168.1.15/8081"
        controlUrl: "www.drewandtrish.com:9000/cameras/192.168.1.15/8081"
        token: $routeParams.token
        proto: "https://"
        stream: '/videostream.cgi'
        control: '/decoder_control.cgi'
        viewUrl: @foscamViewUrl
      }
      ]
    ]

