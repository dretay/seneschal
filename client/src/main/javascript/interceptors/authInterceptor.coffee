define [
    'i/interceptors'
    'underscore'
  ],
(interceptors, _) ->
  'use strict'
  interceptors.factory 'authInterceptor', ($q, $window, $location)->
    (promise)->
      success = (response)-> response
      error =  (response)->
        if response.status == 401 then $location.url('/login')
        $q.reject(response)

      promise.then success, error
