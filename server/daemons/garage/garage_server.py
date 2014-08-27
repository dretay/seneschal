from kombu import Connection, Producer, Exchange, Queue, Consumer, common as kombucommon
import threading, json, time, socket, signal, sys, ConfigParser, re, xmlrpclib, RPi.GPIO as GPIO, datetime
from urllib2 import quote

#
# Executes if the program is started normally, not if imported
#
if __name__ == '__main__':

  #read in config
  settings = ConfigParser.ConfigParser()
  settings.read('../config/site.ini')
  rabbitmqUsername = settings.get('rabbitmq', 'username')
  rabbitmqPassword = settings.get('rabbitmq', 'password')
  rabbitmqHost = settings.get('rabbitmq', 'host')

  #setup rabbitmq connections
  rmqConn = Connection('amqp://'+rabbitmqUsername+':'+rabbitmqPassword+'@'+rabbitmqHost+':5672//')
  rpcProducer= Producer(rmqConn.channel(), serializer="json")
  statusProducer = Producer(rmqConn.channel(), exchange = Exchange('garage.status', type='fanout'), serializer="json")
  queue = Queue(
    name="garage.cmd",
    exchange=Exchange('garage.cmd'),
    channel=rmqConn.channel(),
    durable=False,
    exclusive=False,
    auto_delete=True)

  GPIO.setmode(GPIO.BOARD)

  #trish's door
  GPIO.setup(11, GPIO.IN, GPIO.PUD_UP)
  GPIO.setup(16, GPIO.OUT, initial=GPIO.HIGH)


  #drew's door
  GPIO.setup(7, GPIO.IN, GPIO.PUD_UP)
  GPIO.setup(18, GPIO.OUT, initial=GPIO.HIGH)

  doors = {
    #drew's
    7:{
      "state": False if GPIO.input(7) == 0 else True,
      "timestamp": (datetime.datetime.now() - datetime.datetime(1970,1,1)).total_seconds()
    },
    #trish's
    11:{
      "state": False if GPIO.input(11) == 0 else True,
      "timestamp": (datetime.datetime.now() - datetime.datetime(1970,1,1)).total_seconds()

    }
  }

  def door_state_changed(channel):
    #newState = False if GPIO.input(int(channel)) == 0 else True
    #if newState != doors[channel]["state"]:
    # self.reply_q.put(event)
    doors[channel] = {
      "state": not doors[channel]['state'],
      "timestamp": (datetime.datetime.now() - datetime.datetime(1970,1,1)).total_seconds()
    }
    statusProducer.publish(body = doors)
    print "Door ",channel,"state changed ",doors[channel]

  # #drew's door
  # GPIO.add_event_detect(7, GPIO.BOTH, callback=door_state_changed)

  # #trish's door
  # GPIO.add_event_detect(11, GPIO.BOTH, callback=door_state_changed)


  #setup message handlers
  def rpcReply(message, req):
    rpcProducer.publish(body=message, **dict({'routing_key': req.properties['reply_to'],
                'correlation_id': req.properties.get('correlation_id'),
                'content_encoding': req.content_encoding}))


  def toggle_door(message=None, args=None):
    doorChannel = message['channel']
    print "Toggling door on channel",doorChannel

    GPIO.output(doorChannel, False)
    time.sleep(1)
    GPIO.output(doorChannel, True)

  def dump_door_timers(message=None, args=None):
    rpcReply(doors, args)

  def on_request(body, req):
    message = json.loads(body)
    print "Received message ",message
    sys.stdout.flush()
    operations = {
      "dump_door_timers" : dump_door_timers,
      "toggle_door" : toggle_door
    }
    operations[message['operation']](message, req)

  #lets light this candle
  consumer = Consumer(rmqConn.channel(), queues = queue, auto_declare=True, callbacks=[on_request])
  consumer.consume(no_ack=True)

  print "Garage doors started",doors
  while True:
    try:
      rmqConn.drain_events(timeout=2)
    except socket.timeout:

      if GPIO.input(7) != doors[7]['state']:
        door_state_changed(7)
      if GPIO.input(11) != doors[11]['state']:
        door_state_changed(11)
