exports.config =
  minMimosaVersion:"1.0.1"
  modules: [
    'server'
    'require'
    'minify'
    'bower'
    'require-lint'
    'mimosa-jshint'
    'mimosa-csslint'
    'coffeescript'
    'copy'
    'stylus'
    # 'mimosa-karma-enterprise'
  ]
  server:
    defaultServer:
      enabled: true
      onePager: true
    port: 3000
    views:
      compileWith: 'html'
      extension: 'html'
      path: 'src/main/html'
  # karma:
  #   configFile: 'src/test/karma-unit.conf.js'
  #   externalConfig: true
  # copy:
    # extensions: ["csv", "properties", "js","css","png","jpg","jpeg","gif","html","eot","svg","ttf","woff","otf","yaml","kml","ico","htc","htm","json","txt","xml","xsd","map"]
  minify:
    exclude:[/\.min\./, "coffeescript/main.js", "coffeescript/app.js"]
  watch:
    sourceDir: 'src/main'
    javascriptDir: 'coffeescript'
    compiledDir: 'build/resources/main'
  vendor:
    javascripts: "coffeescript/vendor"
  csslint:
    compiled: false
    copied: false
    vendor: false
  jshint:
    exclude: [/.*legacy\/js\/.*/]
  require:
    optimize:
      overrides:
        optimize: "none"


  bower:
    exclude: [/.*legacy\/js\/.*/]
    bowerDir:
      clean:false
    copy:
      outRoot: "managed"
      mainOverrides:
        "font-awesome":["fonts/fontawesome-webfont.woff","fonts/fontawesome-webfont.svg","fonts/FontAwesome.otf","fonts/fontawesome-webfont.eot","fonts/fontawesome-webfont.ttf","css/font-awesome.css"]
        "angular-motion":["dist/angular-motion.css"]
        "stomp-websocket":["lib/stomp.js"]
        "requirejs-domready":["domReady.js"]
        "requirejs-i18n":["i18n.js"]
        "jquery.svg": ["jquery.svg.js"]
