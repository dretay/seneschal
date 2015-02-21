UpnpControlPoint = require("upnp-controlpoint/lib/upnp-controlpoint").UpnpControlPoint
wemo = require("upnp-controlpoint/lib/wemo")
_ = require("underscore")
log = require("winston")
amqp = require('amqp')
async = require('async')
mysensors_db = require "../mysensors/mysensors_db"
mysensors_constants = require "../mysensors/mysensors_constants"

injectParams = (callback)->
  switches = []
  callback null, switches

class WemoControlleePlus extends wemo.WemoControllee
  getBinaryState: -> @binaryState
  storeBinaryState: (binaryState)->
    log.info "Storing new binary state for #{@device.friendlyName}: #{binaryState}"
    if binaryState == "1" or binaryState == 1 or binaryState == true
      @binaryState = true
    else
      @binaryState = false
  retrieveBinaryState: (callback)->
    @eventService.callAction "GetBinaryState", {}, (err, result)->
      if err
        log.error "got err when performing action: #{err}"
      else
        if result.match /<BinaryState>(\d)<\/BinaryState>/
          callback null, RegExp.$1
        else
          callback "Unknown error: #{result}"


#connect to the amqp broker
connectToBroker = (switches, callback)->
  log.info("setting up amqp connections")
  parser = new require('inireader').IniReader()
  parser.load('../config/site.ini')
  rabbitmqUsername = parser.param('rabbitmq.username')
  rabbitmqPassword = parser.param('rabbitmq.password')
  rabbitmqHost = parser.param('rabbitmq.host')
  connection = amqp.createConnection
    url: "amqp://"+rabbitmqUsername+":"+rabbitmqPassword+"@"+rabbitmqHost+":5672"
  connection.on 'error', (exception)->
    log.error "AMQP connection error: #{exception.message}"
  connection.addListener 'ready', ->
    log.info("successfully connected to amqp broker")
    connection.exchange "wemo.status",{type: "fanout", durable: true, autoDelete: false}, (fanoutExchange)->
      connection.queue 'wemo.cmd',  (q)->
        connection.exchange "wemo.cmd",{type: "direct", durable: true, autoDelete: false}, (directExchange)->
            q.bind directExchange, '', ->
              log.info("amqp connections established")
              #setup AMQP listeners
              q.subscribe (message, headers, deliveryInfo, messageObject)->
                log.info("received amqp command: #{message.data.toString()}")
                message = JSON.parse(message.data.toString())

                if message.operation == "updateSensorMetadata"
                  {node_id,sensor_id,metadata} = message
                  mysensors_db.updateSensorMetadata node_id,sensor_id, metadata



                if message.operation == "list_switches"
                  mysensors_db.getNewestReadingsForType mysensors_constants.S_LIGHT, 'wemo', (err, readings)->
                    connection.publish deliveryInfo.replyTo, readings

                else if message.operation == "toggle_on"
                  mySwitch = _.find switches, (mySwitch)->
                    mySwitch.device.friendlyName == message.switchName
                  mySwitch.setBinaryState true

                else if message.operation == "toggle_off"
                  mySwitch = _.find switches, (mySwitch)->
                    mySwitch.device.friendlyName == message.switchName
                  mySwitch.setBinaryState false

              #setup upnp event listener
              deviceListener = (device, value)->
                fanoutExchange.publish "",
                  name: device.friendlyName
                  status: value


              log.info("completed binding and subscribing to broker")
              callback(null,switches, deviceListener)

setupUpnpControlPoint = (switches, deviceListener, callback)->
  log.info("upnp control point starting up")
  cp = new UpnpControlPoint()
  cp.on "device", (device)->
    if device.deviceType == wemo.WemoControllee.deviceType || device.deviceType == "urn:Belkin:device:lightswitch:1"
      log.info "Discovered switch "+device.friendlyName
      mysensors_db.createNodeBySketchnameIfMissing device.friendlyName, "wemo", (err, nodeId)->
        mysensors_db.saveSensor nodeId, 0, mysensors_constants.S_LIGHT, (err)->
          wemoSwitch = new WemoControlleePlus(device)
          wemoSwitch.retrieveBinaryState (err, binaryState)->
            if not err
              mysensors_db.saveValue nodeId, 0, mysensors_constants.S_LIGHT, binaryState
              wemoSwitch.storeBinaryState binaryState
              switches.push wemoSwitch

          wemoSwitch.on "BinaryState", (value)->
            mysensors_db.saveValue nodeId, 0, mysensors_constants.S_LIGHT, value
            wemoSwitch.storeBinaryState value
            deviceListener(device, value)
    else
      console.log("Ignoring discovered device "+device.friendlyName)
  cp.search()
  setInterval ->
    cp.search()
  , 60000

  #wait 5 seconds then continue startup
  setTimeout (->
    log.info("upnp control point discovery finished")
    callback null, switches), 5000

async.waterfall [injectParams, connectToBroker,setupUpnpControlPoint], (err,config)->
  if err
    console.log(err)
