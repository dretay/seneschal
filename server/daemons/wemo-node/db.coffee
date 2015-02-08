async = require 'async'
_ = require "underscore"
log = require "winston"
knex_lib = require 'knex'

parser = new require('inireader').IniReader()
parser.load('../config/site.ini')

Knex = knex_lib
  # debug: true
  client: 'postgres'
  connection:
    host: parser.param 'mysensors.host'
    user: parser.param 'mysensors.user'
    password: parser.param 'mysensors.password'
    database: parser.param 'mysensors.database'
    charset: 'utf8'
,
  pool:
    max: 10
    min: 2
    idleTimeoutMillis: 30000
    log: false




exports.Knex = Knex
