window.loggingLevel = 'all';

requirejs.config({
  paths: {
    c: "controllers",
    d: "directives",
    s: "services",
    f: "filters",
    p: "providers",
    m: "mixins",
    r: "resources",

    //angular
    angular: 'vendor/managed/angular/angular',
    angularRoute: 'vendor/managed/angular-route/angular-route',
    angularResource: 'vendor/managed/angular-resource/angular-resource',

    domReady: 'vendor/managed/requirejs-domready/domReady',
    underscore: 'vendor/managed/underscore-amd/underscore',
    jquery: 'vendor/managed/jquery/jquery',
    jqueryMigrate: 'vendor/unmanaged/jquery-migrate-1.2.1.min',
    jquerySvg: 'vendor/unmanaged/jquery.svg',

    stomp: 'vendor/managed/stomp-websocket/stomp',
    sockjs: 'vendor/managed/sockjs/sockjs',


  },
  shim: {
    'jquerySvg':{
      deps: ['jquery', 'jqueryMigrate']
    },
    'angularResource': {
      deps: ['angular']
    },
    'angular': {
      exports: 'angular',
      deps: ['jquery']
    },
    'angularRoute': {
      deps: ['angular']
    },
    'bootstrap': {
      deps: ['app']
    },
    'stomp':{
      exports: 'Stomp',
      deps: ['sockjs']
    },
    'sockjs':{
      exports: 'SockJS'
    }
  },
  priority: ["angular"]
});

require(['app', 'bootstrap', 'c/home'], function(app) {
  var routes;
  routes = function($routeProvider) {
    return $routeProvider.when('/home/:token/:page', {
      reloadOnSearch: false,
      templateUrl: '/html/home.html',
      controller: 'home'
    }).when('/home/:token', {
      templateUrl: '/html/home.html',
      controller: 'home'
    }).otherwise({
      redirectTo: '/login'
    });
  };
  app.config(['$routeProvider', routes]);

  app.config(function(webStompProvider) {
    webStompProvider.hostname = 'www.drewandtrish.com';
  });


});
