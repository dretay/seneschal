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
    angularAnimate: 'vendor/managed/angular-animate/angular-animate',
    angularTouch: 'vendor/managed/angular-touch/angular-touch',

    //bootstrap
    angularStrap: 'vendor/managed/angular-strap/angular-strap.min',
    twitterBootstrap: 'vendor/managed/bootstrap/bootstrap',

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
    'angularAnimate': {
      deps: ['angular']
    },
    'angularTouch': {
      deps: ['angular']
    },
    'angularStrap': {
      deps: ['angular', 'twitterBootstrap']
    },
    'twitterBootstrap':{
      deps: ['jquery']
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

require(['app', 'bootstrap', 'c/home' ,'c/main', 'c/alarm', 'c/cameras', 'c/lights','c/thermostat'], function(app) {
  var routes;
  routes = function($routeProvider) {
    return $routeProvider.when('/alarm/:token', {
      reloadOnSearch: false,
      templateUrl: '/html/alarm.html',
      controller: 'alarm'
    }).when('/cameras/:token', {
      reloadOnSearch: false,
      templateUrl: '/html/cameras.html',
      controller: 'cameras'
    }).when('/lights/:token', {
      reloadOnSearch: false,
      templateUrl: '/html/lights.html',
      controller: 'lights'
    }).when('/thermostat/:token', {
      reloadOnSearch: false,
      templateUrl: '/html/thermostat.html',
      controller: 'thermostat'
    }).when('/dashboard/:token', {
      templateUrl: '/html/dashboard.html',
      controller: 'dashboard'
    }).otherwise({
      redirectTo: '/login'
    });
  };
  app.config(['$routeProvider', routes]);

  app.config(function(webStompProvider) {
    webStompProvider.hostname = 'www.drewandtrish.com';
  });


});
