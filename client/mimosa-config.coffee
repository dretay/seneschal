exports.config =
  minMimosaVersion:"1.0.1"
  modules: [
    "server"
    "require"
    "require-lint"
    "minify-js"
    "minify-css"
    "bower"
    "jshint"
    "csslint"
    "coffeescript"
    "copy"
    "stylus"
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
        mainConfigFile: "src/main/coffeescript/main.js"
        optimize: "none"


  bower:
    exclude: [/.*legacy\/js\/.*/]
    bowerDir:
      clean:false
    copy:
      outRoot: "managed"
      mainOverrides:
        "angular-motion":["dist/angular-motion.css"]
        "engine.io-client": ["engine.io.js"]
        "font-awesome":["fonts/fontawesome-webfont.woff","fonts/fontawesome-webfont.svg","fonts/FontAwesome.otf","fonts/fontawesome-webfont.eot","fonts/fontawesome-webfont.ttf","css/font-awesome.css"]
        "requirejs-domready":["domReady.js"]
        "stomp-websocket":["lib/stomp.js"]
