UpnpControlPoint = require("upnp-controlpoint/lib/upnp-controlpoint").UpnpControlPoint
wemo = require("upnp-controlpoint/lib/wemo")
_ = require("underscore")
log = require("winston")
amqp = require('amqp')
async = require('async')

injectParams = (callback)->
  switches = []
  callback null, switches

class WemoControlleePlus extends wemo.WemoControllee
  getBinaryState: -> @binaryState
  storeBinaryState: (binaryState)->
    log.info "Storing new binary state for #{@device.friendlyName}: #{binaryState}"
    @binaryState = binaryState
  retrieveBinaryState: (callback)->
    @eventService.callAction "GetBinaryState", {}, (err, result)->
      if err
        log.error "got err when performing action: #{err} => #{buf}"
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
  connection.addListener 'ready', ->
    log.info("successfully connected to amqp broker")
    connection.exchange "lights.status",{type: "fanout", durable: true, autoDelete: false}, (fanoutExchange)->
      connection.queue 'wemo.cmd',  (q)->
        connection.exchange "lights.cmd",{type: "direct", durable: true, autoDelete: false}, (directExchange)->
            q.bind directExchange, '', ->
              log.info("amqp connections established")
              #setup AMQP listeners
              q.subscribe (message, headers, deliveryInfo, messageObject)->
                message = JSON.parse(message.data.toString())
                log.info("received amqp command: #{message.operation}")
                if message.operation == "list_switches"
                  results = _.map switches, (wemoSwitch)->
                    name: wemoSwitch.device.friendlyName
                    status: wemoSwitch.getBinaryState()
                  log.info "Switch Status: #{JSON.stringify results}"

                  connection.publish deliveryInfo.replyTo, results

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
      log.info "Found "+device.friendlyName
      wemoSwitch = new WemoControlleePlus(device)
      wemoSwitch.retrieveBinaryState (err, binaryState)->
        if not err
          wemoSwitch.storeBinaryState binaryState
          switches.push wemoSwitch

      wemoSwitch.on "BinaryState", (value)->
        wemoSwitch.storeBinaryState value
        deviceListener(device, value)

    else
      console.log("Ignoring discovered device "+device.friendlyName)
  cp.search()

  #wait 10 seconds then continue startup
  setTimeout (->
    log.info("upnp control point discovery finished")
    callback null, switches), 10000

async.waterfall [injectParams, connectToBroker,setupUpnpControlPoint], (err,config)->
  if err
    console.log(err)
  else
    log.info("wemo server startup complete")