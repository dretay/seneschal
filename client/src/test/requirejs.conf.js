var tests = Object.keys(window.__karma__.files).filter(function(file){
  return /Spec\.js$/.test(file);
});

requirejs.config({
  baseUrl: '/base/src/main/coffeescript',
  paths: {
    c: "controllers",
    d: "directives",
    s: "services",
    f: "filters",
    p: "providers",
    m: "mixins",
    r: "resources",

    angular: 'vendor/managed/angular/angular',
    angularRoute: 'vendor/managed/angular-route/angular-route',
    angularResource: 'vendor/managed/angular-resource/angular-resource',
    angularMocks: 'vendor/managed/angular-mocks/angular-mocks',
    angularAmp: 'vendor/managed/angular-ampjs/ngAmpjs.min',

    shortBus: 'vendor/managed/ampjs/ShortBus.min',
    domReady: 'vendor/managed/requirejs-domready/domReady',
    underscore: 'vendor/managed/underscore-amd/underscore',
    stomp: 'vendor/managed/stomp-websocket/stomp',
    flog: 'vendor/managed/flog/flog',
    uuid: 'vendor/managed/node-uuid/uuid',
    sockjs: 'vendor/managed/sockjs/sockjs',
    jquery: 'vendor/managed/jquery/jquery',
    LRUCache: 'vendor/managed/node-lru-cache/lru-cache',
    JSEncrypt: 'vendor/managed/jsencrypt/jsencrypt.min',
    CryptoJSLib: 'vendor/managed/cryptojslib',
    CryptoJS : 'vendor/managed/cryptojslib/core',
    Hashtable : 'vendor/managed/jshashtable/hashtable'
  },
  shim: {
    'angularMocks':{
      deps: ['angular'],
      exports: 'angular.mock'
    },
    'angularAmp': {
      deps: ['angular']
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
    'stomp': {
      exports: 'Stomp'
    },
    'sockjs': {
      exports: 'SockJS'
    },
    'uuid': {
      exports: 'uuid'
    },
    'JSEncrypt':{
      exports: "JSEncrypt"
    },
    'CryptoJSLib/cipher-core':{
      deps: ['CryptoJSLib/core']
    },
    "CryptoJSLib/aes":{
      deps: ['CryptoJSLib/core','CryptoJSLib/cipher-core']
    },
    'CryptoJSLib/pbkdf2':{
      deps: ['CryptoJSLib/core', 'CryptoJSLib/hmac', 'CryptoJSLib/sha384']
    },
    'CryptoJSLib/hmac':{
      deps: ['CryptoJSLib/core']
    },
    'CryptoJSLib/sha384':{
      deps: ['CryptoJSLib/core', 'CryptoJSLib/x64-core', 'CryptoJSLib/sha512']
    },
    'CryptoJSLib/x64-core':{
      deps: ['CryptoJSLib/core']
    },
    'CryptoJSLib/sha512':{
      deps: ['CryptoJSLib/core', 'CryptoJSLib/x64-core']
    },
    'CryptoJSLib/enc-base64':{
      deps: ['CryptoJSLib/core']
    },
    'Hashtable':{
      exports: 'Hashtable'
    }
  },
  deps: tests,
  callback: window.__karma__.start
});
