window.loggingLevel = 'all';
window.debug = {
  log: console.log
};

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
    angularUi: 'vendor/managed/angular-bootstrap/ui-bootstrap-tpls',
    angularRoute: 'vendor/managed/angular-route/angular-route',
    angularResource: 'vendor/managed/angular-resource/angular-resource',
    angularAnimate: 'vendor/managed/angular-animate/angular-animate',
    angularTouch: 'vendor/managed/angular-touch/angular-touch',
    angularSanitize: 'vendor/managed/angular-sanitize/angular-sanitize',

    //bootstrap
    //angularStrap: 'vendor/managed/angular-strap/angular-strap.min',
    //angularStrapTpl: 'vendor/managed/angular-strap/angular-strap.tpl.min',
    twitterBootstrap: 'vendor/managed/bootstrap/bootstrap',

    domReady: 'vendor/managed/requirejs-domready/domReady',
    underscore: 'vendor/managed/underscore-amd/underscore',
    jquery: 'vendor/managed/jquery/jquery',
    jqueryMigrate: 'vendor/unmanaged/jquery-migrate-1.2.1.min',
    jquerySvg: 'vendor/unmanaged/jquery.svg',

    //utils
    stomp: 'vendor/managed/stomp-websocket/stomp',
    sockjs: 'vendor/managed/sockjs/sockjs',
    moment: 'vendor/managed/moment/moment'


  },
  shim: {
    'jquerySvg':{
      deps: ['jquery', 'jqueryMigrate']
    },
    'angularUi': {
      deps: ['angular']
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
    'angularSanitize': {
      deps: ['angular']
    },
    /*'angularStrap': {
      deps: ['angular', 'twitterBootstrap']
    },
    'angularStrapTpl': {
      deps: ['angularStrap']
    },*/
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
    },
    'moment':{
      exports: 'moment'
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
