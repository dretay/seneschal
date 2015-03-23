window.loggingLevel = 'error';
window.debug = null;


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

      ace: 'vendor/managed/ace-builds/ace',
      angular: 'vendor/managed/angular/angular',
      angularAMD: 'vendor/managed/angularAMD/angularAMD',
      angularAnimate: 'vendor/managed/angular-animate/angular-animate',
      angularBootstrapSwitch: 'vendor/managed/angular-bootstrap-switch/angular-bootstrap-switch',
      angularContextMenu: "vendor/managed/angular-bootstrap-contextmenu/contextMenu",
      angularDragDrop: 'vendor/managed/angular-dragdrop/angular-dragdrop',
      angularNvd3Directives: 'vendor/managed/angularjs-nvd3-directives/angularjs-nvd3-directives',
      angularResource: 'vendor/managed/angular-resource/angular-resource',
      angularRoute: 'vendor/managed/angular-route/angular-route',
      angularSanitize: 'vendor/managed/angular-sanitize/angular-sanitize',
      angularTouch: 'vendor/managed/angular-touch/angular-touch',
      angularUi: 'vendor/managed/angular-bootstrap/ui-bootstrap-tpls',
      angularUiAce: 'vendor/managed/angular-ui-ace/ui-ace',
      angularUiSelect: 'vendor/managed/angular-ui-select/select',
      bootstrapSwitch: 'vendor/managed/bootstrap-switch/bootstrap-switch',
      chroma: 'vendor/managed/chroma-js/chroma',
      d3: 'vendor/managed/d3/d3',
      domReady: 'vendor/managed/requirejs-domready/domReady',
      jqueryPxEm: 'vendor/unmanaged/pxem.jQuery',
      jquery: 'vendor/managed/jquery/jquery',
      jqueryMigrate: 'vendor/unmanaged/jquery-migrate-1.2.1.min',
      jquerySvg: 'vendor/unmanaged/jquery.svg',
      jqueryUI: 'vendor/managed/jquery-ui/jquery-ui',
      moment: 'vendor/managed/moment/moment',
      ngBiscuit: 'vendor/managed/ngWig/ng-biscuit',
      ngTable: 'vendor/managed/ng-table/ng-table',
      nvd3: 'vendor/managed/nvd3/nv.d3',
      smoothie: "vendor/managed/smoothie/smoothie",
      sockjs: 'vendor/managed/sockjs/sockjs',
      stomp: 'vendor/managed/stomp-websocket/stomp',
      twitterBootstrap: 'vendor/managed/bootstrap/bootstrap',
      underscore: 'vendor/managed/underscore-amd/underscore',
      uuid: 'vendor/managed/node-uuid/uuid'
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
      'angularBootstrapSwitch':{
        deps: ['angular', 'bootstrapSwitch']
      },
      'angularContextMenu':{
        deps: ['angular']
      },
      'angularDragDrop':{
        deps: ['angular', 'jqueryUI']
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
      'angularUiAce':{
        deps: ['angular','ace']
      },
      'angularUiSelect':{
        deps: ['angular']
      },
      'bootstrapSwitch':{
        deps: ['jquery']
      },
      'jqueryPxEm': {
        deps: ['jquery']
      },
      'jquerySvg': {
        deps: ['jquery', 'jqueryMigrate']
      },
      'jqueryUI':{
        deps: ['jquery']
      },
      'moment': {
        exports: 'moment'
      },
      'ngBiscuit': {
        deps: ['angular']
      },
      'angularNvd3Directives': {
        deps: ['angular', 'nvd3']
      },
      'nvd3':{
        deps: ['d3']
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
      },
      'uuid': {
        exports: 'uuid'
      }
    },
    deps: ["app"]
});
console.debug("SENESCHAL::main Loading application dependencies");
