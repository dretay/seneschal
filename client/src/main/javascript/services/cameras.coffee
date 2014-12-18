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
      "#{@proto}#{@videoUrl}"
    foscamViewUrl: ->
      "#{@proto}#{@videoUrl}#{@stream}?rate=3"
    query: ()->
      [
#        {
#          name: "Garage"
#          status: false
#          floor: "mainFloor"
#          location:
#            left: 68.5
#            top: 41
#            rotation: 0
#          videoUrl: "www.drewandtrish.com/cameras/192.168.1.6/8081/"
#          proto: "https://"
#        # inverted: true
#          viewUrl: @mediaViewUrl
#
#        }

        {
          name: "Porch"
          status: false
          floor: "mainFloor"
          location:
            left: 39
            top: 76.5
            rotation: 0
          videoUrl: "www.drewandtrish.com/proxiedCameras/192.168.1.20/8080"
          controlUrl: "www.drewandtrish.com/cameras/192.168.1.18/8083"
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
            left: 28
            top: 71
            rotation: 180
          videoUrl: "www.drewandtrish.com/proxiedCameras/192.168.1.20/8080"
          controlUrl: "www.drewandtrish.com/cameras/192.168.1.17/8080"
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
            top: 8.5
            rotation: 0
          videoUrl: "www.drewandtrish.com/proxiedCameras/192.168.1.20/8080"
          controlUrl: "www.drewandtrish.com/cameras/192.168.1.16/8082"
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
            left: 29
            top: 9
            rotation: -90
          videoUrl: "www.drewandtrish.com/proxiedCameras/192.168.1.20/8080"
          controlUrl: "www.drewandtrish.com/cameras/192.168.1.15/8081"
          proto: "https://"
          stream: '/basement'
          control: '/decoder_control.cgi'
          viewUrl: @foscamViewUrl
        }
      ]
  ]

