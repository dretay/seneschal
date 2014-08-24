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
  GPIO.setup(7, GPIO.IN, pull_up_down = GPIO.PUD_DOWN)
  GPIO.setup(11, GPIO.IN, pull_up_down = GPIO.PUD_DOWN)

  doors = {
    #drew's
    7:{
      "state": False if GPIO.input(7) == 1 else True,
      "timestamp": (datetime.datetime.now() - datetime.datetime(1970,1,1)).total_seconds()
    },
    #trish's
    11:{
      "state": False if GPIO.input(11) == 1 else True,
      "timestamp": (datetime.datetime.now() - datetime.datetime(1970,1,1)).total_seconds()

    }
  }
  def door_state_changed(channel):
    # self.reply_q.put(event)
    doors[channel] = {
      "state": not doors[channel]['state'],
      "timestamp": (datetime.datetime.now() - datetime.datetime(1970,1,1)).total_seconds()
    }
    statusProducer.publish(body = doors)
    print "Door ",channel,"state changed ",doors[channel]

  #drew's door
  GPIO.add_event_detect(7, GPIO.BOTH, callback=door_state_changed, bouncetime=5000)

  #trish's door
  GPIO.add_event_detect(11, GPIO.BOTH, callback=door_state_changed, bouncetime=5000)


  #setup message handlers
  def rpcReply(message, req):
    rpcProducer.publish(body=message, **dict({'routing_key': req.properties['reply_to'],
                'correlation_id': req.properties.get('correlation_id'),
                'content_encoding': req.content_encoding}))


  def dump_door_timers(message=None, args=None):
    rpcReply(doors, args)

  def on_request(body, req):
    message = json.loads(body)
    print "Received message ",message
    sys.stdout.flush()
    operations = {
      "dump_door_timers" : dump_door_timers
    }
    operations[message['operation']](message, req)

  #lets light this candle
  consumer = Consumer(rmqConn.channel(), queues = queue, auto_declare=True, callbacks=[on_request])
  consumer.consume(no_ack=True)

  print "Garage doors started",doors
  while True:
    try:
      rmqConn.drain_events(timeout=0.1)
    except socket.timeout:
      None
