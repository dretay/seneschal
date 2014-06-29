define ['require', 'angular'], (require, angular) ->
    'use strict'
    require ['domReady!'], (document) ->
        try
          angular.bootstrap document, ['app']
        catch err
          alert err
