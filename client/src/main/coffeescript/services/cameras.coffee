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
      [
        {
          name: "Garage"
          status: false
          floor: "mainFloor"
          location:
            left: 70.5
            top: 43
            rotation: 0
          videoUrl: "www.drewandtrish.com/cameras/192.168.1.28/8081/"
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
            left: 41
            top: 74.5
            rotation: 0
          videoUrl: "www.drewandtrish.com/proxiedCameras/192.168.1.2/8080"
          controlUrl: "www.drewandtrish.com/cameras/192.168.1.18/8083"
          token: $routeParams.token
          proto: "https://"
          inverted: true
          stream: '/porch'
          control: '/decoder_control.cgi'
          viewUrl: @foscamViewUrl
        }
        {
          name: "Front Door"
          status: false
          floor: "mainFloor"
          location:
            left: 30
            top: 70
            rotation: 180
          videoUrl: "www.drewandtrish.com/proxiedCameras/192.168.1.2/8080"
          controlUrl: "www.drewandtrish.com/cameras/192.168.1.17/8080"
          token: $routeParams.token
          proto: "https://"
          stream: '/frontdoor'
          control: '/decoder_control.cgi'
          viewUrl: @foscamViewUrl
        }
        {
          name: "Living Room"
          status: false
          floor: "mainFloor"
          location:
            left: 47
            top: 9.5
            rotation: 0
          videoUrl: "www.drewandtrish.com/proxiedCameras/192.168.1.2/8080"
          controlUrl: "www.drewandtrish.com/cameras/192.168.1.16/8082"
          token: $routeParams.token
          proto: "https://"
          stream: '/livingroom'
          control: '/decoder_control.cgi'
          viewUrl: @foscamViewUrl
        }
        {
          name: "Walk Out"
          status: false
          floor: "basement"
          location:
            left: 32
            top: 14
            rotation: -90
          videoUrl: "www.drewandtrish.com/proxiedCameras/192.168.1.2/8080"
          controlUrl: "www.drewandtrish.com/cameras/192.168.1.15/8081"
          token: $routeParams.token
          proto: "https://"
          stream: '/basement'
          control: '/decoder_control.cgi'
          viewUrl: @foscamViewUrl
        }
      ]
    ]

