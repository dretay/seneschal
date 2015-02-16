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
#    "require-lint"
    "server"
    "stylus"
    "sass"
    "underscore"
    "html-templates"
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
    extensions: ["cur", "mp3", "ogg", "wav", "js","css","png","jpg","jpeg","gif","html","eot","svg","ttf","woff","otf","yaml","kml","ico","htc","htm","json","txt","xml","xsd","map","md","mp4", "manifest"]

  minifyJS:
    exclude:[/\.min\./, "javascript/main.js"]
    mangleNames: false

  watch:
    sourceDir: 'src/main'
    javascriptDir: 'javascript'
    compiledDir: 'build/resources/main'
  vendor:
    javascripts: "javascript/vendor"
  csslint:
    compiled: false
    copied: false
    vendor: false
  jshint:
    exclude: [/.*legacy\/js\/.*/]

  require:
    optimize:
      overrides:
        mainConfigFile: "src/main/javascript/main.js"
        optimize: "none"
  bower:
    exclude: [/.*legacy\/js\/.*/]
    bowerDir:
      clean:false
    copy:
      outRoot: "managed"
      mainOverrides:
        "ace-builds":["src-noconflict/ace.js", "src-noconflict/mode-coffee.js","src-noconflict/worker-coffee.js", "src-noconflict/theme-twilight.js"]
        "angular-motion":["dist/angular-motion.css"]
        "requirejs-domready":["domReady.js"]
        "stomp-websocket":["lib/stomp.js"]
  template:
    output: [
      (
        folders: ["javascript/ejs"]
        outputFileName: "javascript/ejs/templates"
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
      # bootstrap
      {
        src: "stylesheets/vendor/managed/bootstrap/glyphicons-halflings-regular.eot"
        dest: "fonts/glyphicons-halflings-regular.eot"
      }
      {
        src: "stylesheets/vendor/managed/bootstrap/glyphicons-halflings-regular.svg"
        dest: "fonts/glyphicons-halflings-regular.svg"
      }
      {
        src: "stylesheets/vendor/managed/bootstrap/glyphicons-halflings-regular.ttf"
        dest: "fonts/glyphicons-halflings-regular.ttf"
      }
      {
        src: "stylesheets/vendor/managed/bootstrap/FontAwesome/glyphicons-halflings-regular.woff"
        dest: "fonts/glyphicons-halflings-regular.woff"
      }

      # font awesome
      {
        src: "stylesheets/vendor/managed/font-awesome/FontAwesome.otf"
        dest: "fonts/FontAwesome.otf"
      }
      {
        src: "stylesheets/vendor/managed/font-awesome/fontawesome-webfont.eot"
        dest: "fonts/fontawesome-webfont.eot"
      }
      {
        src: "stylesheets/vendor/managed/font-awesome/fontawesome-webfont.svg"
        dest: "fonts/fontawesome-webfont.svg"
      }
      {
        src: "stylesheets/vendor/managed/font-awesome/fontawesome-webfont.ttf"
        dest: "fonts/fontawesome-webfont.ttf"
      }
      {
        src: "stylesheets/vendor/managed/font-awesome/fontawesome-webfont.woff"
        dest: "fonts/fontawesome-webfont.woff"
      }
      {
        src: "stylesheets/vendor/unmanaged/media"
        dest: "media"
      }
    ]
