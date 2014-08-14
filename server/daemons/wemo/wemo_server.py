from ouimeaux.environment import Environment
from ouimeaux.utils import matcher
from ouimeaux.signals import receiver, statechange, devicefound
from kombu import Connection, Producer, Exchange, Queue, Consumer, common as kombucommon


import threading, json, time, socket, signal, sys, requests, ConfigParser, re

env = Environment(with_cache=False)

def dayman():
  rlock = threading.RLock()

  wemoDaemon = WemoDaemon()
  wemoDaemon.setDaemon(True)
  wemoDaemon.start()

  kombuDaemon = KombuDaemon()
  kombuDaemon.setDaemon(True)
  kombuDaemon.start()

  while threading.active_count() > 0:
    time.sleep(0.1)
    if wemoDaemon.isAlive() is not True or kombuDaemon.isAlive() is not True:
      sys.exit()
class KombuDaemon(threading.Thread):
  def __init__(self):
    threading.Thread.__init__(self)
    self.settings = ConfigParser.ConfigParser()
    self.settings.read('../config/site.ini')
    self.rabbitmqUsername = self.settings.get('rabbitmq', 'username')
    self.rabbitmqPassword = self.settings.get('rabbitmq', 'password')
    self.rabbitmqHost = self.settings.get('rabbitmq', 'host')
    self.conn = Connection('amqp://'+self.rabbitmqUsername+':'+self.rabbitmqPassword+'@'+self.rabbitmqHost+':5672//')
  def run(self):
    def toggle_on(message, args):
      print "Turning "+message['switchName']+" on..."
      sys.stdout.flush()
      switch = env.get_switch(message['switchName'])
      rpcReply(switch.on(), args)
      # list_switches()


    def toggle_off(message, args):
      print "Turning "+message['switchName']+" off..."
      sys.stdout.flush()
      switch = env.get_switch(message['switchName'])
      rpcReply(switch.off(), args)
      # list_switches()


    def list_switches(message=None, args=None):
      switches = []
      if message != None and args != None:
        for switch in env.list_switches():
          switches.append({
            "name": switch,
            "status": env.get_switch(switch).get_state()
            })
        print "listing finished dumping to json"
        print json.dumps(switches)
        sys.stdout.flush()
        #respond immediately to the guy that asked
        rpcReply(switches, args)

      env.discover(seconds=5)
      for switch in env.list_switches():
        switches.append({
          "name": switch,
          "status": env.get_switch(switch).get_state()
          })
      print "listing finished dumping to json"
      print json.dumps(switches)
      sys.stdout.flush()

      #send out an update to everyone since we have some new data (and the wemo status listeners don't always work)
      # statusProducer.publish(body = switches)

    def rpcReply(message, req):
      #this is so retarded... stomp leaves the /temp-queue in the header... so we need to strip it off
      #or it won't get routed to the appropriate queue
      replyTo = re.search('\/.*\/(.*)', req.properties['reply_to']).group(1)
      rpcProducer.publish(body=message, **dict({'routing_key': replyTo,
                  'correlation_id': req.properties.get('correlation_id'),
                  'content_encoding': req.content_encoding}))
    operations = {
      "list_switches" : list_switches,
      "toggle_on" : toggle_on,
      "toggle_off" : toggle_off,
      "status" : toggle_on
    }
    def on_request(body, req):
      message = json.loads(body)
      print "Received message ",message
      sys.stdout.flush()
      operations[message['operation']](message, req)
    rpcProducer= Producer(self.conn.channel(), serializer="json")
    statusProducer = Producer(self.conn.channel(), exchange = Exchange('lights.status', type='fanout'), serializer="json")
    queue = Queue(
      name="wemo.cmd",
      exchange=Exchange('lights.cmd'),
      channel=self.conn.channel(),
      durable=False,
      exclusive=False,
      auto_delete=True)
    consumer = Consumer(self.conn.channel(), queues = queue, auto_declare=True, callbacks=[on_request])
    consumer.consume(no_ack=True)
    print "WeMo command thread started"
    sys.stdout.flush()

    while True:
      self.conn.drain_events()

class WemoDaemon(threading.Thread):
  def __init__(self):
    threading.Thread.__init__(self)
    self.settings = ConfigParser.ConfigParser()
    self.settings.read('../config/site.ini')
    self.rabbitmqUsername = self.settings.get('rabbitmq', 'username')
    self.rabbitmqPassword = self.settings.get('rabbitmq', 'password')
    self.rabbitmqHost = self.settings.get('rabbitmq', 'host')
    self.conn = Connection('amqp://'+self.rabbitmqUsername+':'+self.rabbitmqPassword+'@'+self.rabbitmqHost+':5672//')
  def run(self):
    @receiver(devicefound)
    def found(sender, **kwargs):
      print "Found device:", sender.name
      sys.stdout.flush()

    @receiver(statechange)
    def motion(sender, **kwargs):
      producer.publish(exchange = 'lights.status',
        routing_key = "",
        body = {
          "name": sender.name,
          "status": "on" if kwargs.get('state') else "off"
          })
      print "{} state is {state}".format(
        sender.name, state="on" if kwargs.get('state') else "off")

    producer = Producer(self.conn.channel(), exchange = Exchange('lights.status', type='fanout'), serializer="json")
    env.start()
    env.discover(60)
    print "WeMo update thread started"
    sys.stdout.flush()
    try:
      env.wait()
    except requests.ConnectionError as e:
      print "WEMO Connection error... exiting!"
      sys.stdout.flush()
      sys.exit()
#
# Executes if the program is started normally, not if imported
#
if __name__ == '__main__':
  # Call the mainfunction that sets up threading.
  dayman()
