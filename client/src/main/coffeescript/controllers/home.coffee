define [
  'c/controllers'
  'underscore'
  'jquery'
  'f/doubleEncodeURIComponent'
  'c/lights'
  'c/cameras'
  'c/alarm'
  'c/dashboard'
  'c/thermostat'
  's/lights'
  'd/light'
],
(controllers, _, $) ->
  'use strict'

  controllers.controller 'home', ['$scope', '$routeParams', '$timeout', ($scope, $routeParams, $timeout) ->

    $scope.routeParams = $routeParams
    $scope.cfg = {}
    $scope.cfg.token = $routeParams.token
    $scope.cfg.pageTitle = ""

    $scope.setPage = (page)->
      $scope.cfg.page = "/html/#{page}.html"

    if $routeParams.page?
      $scope.setPage($routeParams.page)
    else
      $scope.setPage("lights")


    $scope.openMenu = ->
      unless $('div.content').hasClass('inactive')
        #Remove circle
        $('div.circle').remove()

        #Slide and scale content
        $('div.content').addClass('inactive')
        $timeout (->$('div.content').addClass('flag')), 100


        #Change status bar
        $('div.status').fadeOut 100, ->
          $(this).toggleClass('active').fadeIn(300);


        #Slide in menu links
        timer = 0
        $.each $('li'), (i,v)->
          timer = 40 * i
          $timeout (->$(v).addClass('visible')), timer

      $scope.closeMenu = ->
        $('div.content').removeClass('inactive flag')

        #Change status bar
        $('div.status').fadeOut 100, ->
          $(this).toggleClass('active').fadeIn(300)

        #Reset menu
        $timeout (->$('li').removeClass('visible')), 300
  ]