define ['require', 'angular'], (require, angular) ->
    'use strict'
    require ['domReady!'], (document) ->
        try
          console.debug("SENESCHAL::bootstrap dom ready, bootstrapping angular into the page");
          angular.bootstrap document, ['app']
        catch err
          alert err
