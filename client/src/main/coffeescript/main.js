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
        twitterBootstrap: 'vendor/managed/bootstrap/bootstrap',

        //3rd party libraries
        chroma: 'vendor/managed/chroma-js/chroma',
        domReady: 'vendor/managed/requirejs-domready/domReady',
        engineio: 'vendor/managed/engine.io-client/engine.io',
        jquery: 'vendor/managed/jquery/jquery',
        jqueryMigrate: 'vendor/unmanaged/jquery-migrate-1.2.1.min',
        jquerySvg: 'vendor/unmanaged/jquery.svg',
        ngTable: 'vendor/managed/ng-table/ng-table',
        smoothie: "vendor/managed/smoothie-bower/smoothie",
        underscore: 'vendor/managed/underscore-amd/underscore',

        //utils
        stomp: 'vendor/managed/stomp-websocket/stomp',
        sockjs: 'vendor/managed/sockjs/sockjs',
        moment: 'vendor/managed/moment/moment'


    },
    shim: {
        'angular': {
            exports: 'angular',
            deps: ['jquery']
        },
        'angularAnimate': {
            deps: ['angular']
        },
        'angularResource': {
            deps: ['angular']
        },
        'angularRoute': {
            deps: ['angular']
        },
        'angularSanitize': {
            deps: ['angular']
        },
        'angularTouch': {
            deps: ['angular']
        },
        'angularUi': {
            deps: ['angular']
        },
        'bootstrap': {
            deps: ['app']
        },
        'jquerySvg': {
            deps: ['jquery', 'jqueryMigrate']
        },
        'moment': {
            exports: 'moment'
        },
        'ngTable': {
            deps: ['angular']
        },
        'sockjs': {
            exports: 'SockJS'
        },
        'stomp': {
            exports: 'Stomp',
            deps: ['sockjs']
        },
        'twitterBootstrap': {
            deps: ['jquery']
        }
    },
    priority: ["angular"]
});

require(['app', 'bootstrap', 'c/main', 'c/daemons', 'c/vmstats', 'c/router', 'c/controls', 'c/thermostat', 'f/doubleEncodeURIComponent'], function (app) {
    var routes;
    routes = function ($routeProvider) {
        return $routeProvider.when('/admin/daemons/:token', {
            reloadOnSearch: false,
            templateUrl: '/html/daemons.html',
            controller: 'daemons'
        }).when('/admin/router/:token', {
            reloadOnSearch: false,
            templateUrl: '/html/router.html',
            controller: 'router'
        }).when('/admin/vmstats/:token', {
            reloadOnSearch: false,
            templateUrl: '/html/vmstats.html',
            controller: 'vmstats'
        }).when('/cameras/:token', {
            reloadOnSearch: false,
            templateUrl: '/html/cameras.html',
            controller: 'cameras'
        }).when('/controls/:floor/:token', {
            reloadOnSearch: false,
            templateUrl: '/html/controls.html',
            controller: 'controls'
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

    app.config(function (webStompProvider) {
        webStompProvider.hostname = 'www.drewandtrish.com';
    });
    app.run(function($rootScope, $location, webStomp) {
        $rootScope.$on("$routeChangeStart", function (event, next, current) {
            //this should be a register not a set
            //https://docs.angularjs.org/guide/module
            webStomp.setToken(next.pathParams.token);
        });
    });



});
