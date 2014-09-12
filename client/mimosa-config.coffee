exports.config =
  minMimosaVersion:"1.0.1"
  modules: [
    "bower"
    "coffeescript"
    "copy"
    "csslint"
    "jshint"
    "just-copy"
    "minify-css"
    "minify-js"
    "require"
    "require-lint"
    "server"
    "stylus"
    "underscore"
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

  copy:
    extensions: ["js","css","png","jpg","jpeg","gif","html","eot","svg","ttf","woff","otf","yaml","kml","ico","htc","htm","json","txt","xml","xsd","map","md","mp4", "manifest"]
  minifyJS:
    exclude:[/\.min\./, "coffeescript/main.js"]
    mangleNames: false

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
  template:
    output: [
      (
        folders: ["html"]
        outputFileName: "coffeescript/ejs/templates"
      )
    ]
  underscore:
    extensions: [ "html" ]
  justCopy:
    paths:[
      "html/index-optimize.html"
      "html/index.html"
      {
        src: "resources/seneschal.manifest"
        dest: "seneschal.manifest"
      }
    ]
