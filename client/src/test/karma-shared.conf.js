module.exports = function(config){
  return{
    basePath: '../../',
    frameworks: [ 'jasmine', 'mocha', 'requirejs', 'chai'],
    files: [
      "../main/javascript/vendor/managed/angular/angular.js",
      "src/test/mocha.conf.js",
      "src/test/requirejs.conf.js",
      {pattern: 'src/main/coffeescript/**/*.js', included: false},
      {pattern: 'src/main/coffeescript/**/*.coffee', included: false},
      "src/main/html/**/*.html"
    ],
    exclude: [ "src/main/coffeescript/main.js" ],
    reporters: [ "dots", "junit", "coverage" ],
    junitReporter: { outputFile: 'test-results.xml' },
    colors : true,
    autoWatch: true,
    // singleRun : true,
    runnerPort : 9100,
    port : 9876,
    reportSlowerThan: 500,
    // browsers : ['PhantomJS'],
    preprocessors : {
      'src/main/coffeescript/**/*.coffee' : 'coverage',
      '**/*.html': 'ng-html2js',
      'src/test/**/*.coffee': 'coffee'
    },
    coffeePreprocessor: {
      options: {
        sourceMap: true,
        bare: true
      }
    },
    coverageReporter : {
      type: 'html',
      dir: 'coverage/'
      // file: 'coverage.xml'
    },
    ngHtml2JsPreprocessor: {
      stripPrefix: 'src/main',
      moduleName: 'templates'
    }
  };
};