define [
  'c/controllers'
  'underscore'
  'jquery'
],
(controllers, _, $) ->
  'use strict'

  controllers.controller 'dashboard', ['$scope', '$timeout', ($scope, $timeout) ->
    cities = [
      name: "Herndon, VA"
      key: "Herndon"
      utc: "-4"
    ]
    monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    info = {}
    current = 0

    init = ->
      date = new Date()
      $(".date").text monthNames[date.getMonth()] + " " + date.getDate()
      $(".year").text date.getFullYear()



      $.getJSON("http://api.openweathermap.org/data/2.5/weather?q=" + cities[0].name + "&callback=?&units=imperial", null, (data) ->
        return  if data.cod is "404"
        info[data.name] =
          name: data.name
          country: data.sys.country
          temp: data.main.temp
          weather: data.weather[0].main
          des: data.weather[0].description
          hum: data.main.humidity
          wind: data.wind.speed
      ).success (data) ->
        update()



    #set the local times in degrees so it shows in the clock
    setTimes = ->
      date = new Date()
      j = 0

      while j < cities.length
        hours = (if (date.getUTCHours() > 11) then date.getUTCHours() - 12 + parseInt(cities[j].utc, 10) else date.getUTCHours() + parseInt(cities[j].utc, 10))
        cities[j].hours = (hours / 12) * 360
        cities[j].minoutes = (date.getUTCMinutes() / 60) * 360
        j++

    #update all information for each place
    update = ->
      $(".update").addClass "anim"
      city = info[cities[0].key]
      $(".place").text cities[0].name
      $(".temp span").html city.temp + "<sup>o</sup>F"
      $(".main").text city.weather
      $(".des").text city.des
      $(".wind span").html city.wind + "m/s"
      $(".humidity span").html city.hum + "%"
      $(".hour").css "transform", "rotate(" + cities[0].hours + "deg)"
      $(".min").css "transform", "rotate(" + cities[0].minoutes + "deg)"
      setTimeout update, 6000

    setTimes()
    init()

    #after fade animation has finished remove the class that caused it so it can be reused
    $(".update").on "webkitAnimationEnd oAnimationEnd msAnimationEnd animationend", ->
      $(".anim").removeClass "anim"

  ]