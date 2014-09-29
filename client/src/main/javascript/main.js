window.loggingLevel = 'error';
window.debug = null


requirejs.config({
    paths: {
        c: "controllers",
        d: "directives",
        f: "filters",
        i: "interceptors",
        m: "mixins",
        p: "providers",
        r: "resources",
        s: "services",

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
        angularAMD: 'vendor/managed/angularAMD/angularAMD',
        chartjs: 'vendor/managed/Chart.js/Chart.min',
        chroma: 'vendor/managed/chroma-js/chroma',
        domReady: 'vendor/managed/requirejs-domready/domReady',
        jquery: 'vendor/managed/jquery/jquery',
        jqueryMigrate: 'vendor/unmanaged/jquery-migrate-1.2.1.min',
        jquerySvg: 'vendor/unmanaged/jquery.svg',
        ngBiscuit: 'vendor/managed/ngWig/ng-biscuit',
        ngTable: 'vendor/managed/ng-table/ng-table',
        nsPopover: 'vendor/managed/nsPopover/nsPopover',
        smoothie: "vendor/managed/smoothie/smoothie",
        tcAngularChartjs: 'vendor/managed/tc-angular-chartjs/tc-angular-chartjs.min',
        underscore: 'vendor/managed/underscore-amd/underscore',
        uuid: 'vendor/managed/node-uuid/uuid',

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
        'angularAMD':{
          deps: ['angular']
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
        'jquerySvg': {
            deps: ['jquery', 'jqueryMigrate']
        },
        'moment': {
            exports: 'moment'
        },
        'ngBiscuit': {
          deps: ['angular']
        },
        'tcAngularChartjs': {
            deps: ['angular','chartjs']
        },
        'ngTable': {
            deps: ['angular']
        },
        'nsPopover': {
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
        },
        'uuid': {
          exports: 'uuid'
        }
    },
    deps: ["app"]
});
console.debug("SENESCHAL::main Loading application dependencies");
