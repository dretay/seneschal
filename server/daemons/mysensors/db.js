var async = require('async');
var _ = require("underscore");
var log = require("winston");
var knex_lib = require('knex');

var parser = new require('inireader').IniReader();
parser.load('../config/site.ini');

Knex = knex_lib({
  client: 'postgres',
  connection:{
    host: parser.param('mysensors.host'),
    user: parser.param('mysensors.user'),
    password: parser.param('mysensors.password'),
    database: parser.param('mysensors.database'),
    charset: 'utf8'
  }
},{
  pool:{
    max: 10,
    min: 2,
    idleTimeoutMillis: 30000,
    log: false
  }
})


exports.Knex = Knex