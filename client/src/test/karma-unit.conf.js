var sharedConfig = require('./karma-shared.conf');

module.exports = function(config){
  var conf = sharedConfig();

  conf.files = conf.files.concat([
    {pattern: 'src/test/unit/**/*.coffee', included: false}
  ]);

  conf.logLevel= config.LOG_INFO;

  config.set(conf);
};