from ouimeaux.environment import Environment
from ouimeaux.utils import matcher
from ouimeaux.signals import receiver, statechange, devicefound
from kombu import Connection, Producer, Exchange, Queue, Consumer, common as kombucommon
from scapy.all import srp,Ether,ARP,conf

import threading, json, time, socket, signal, sys, requests, ConfigParser, re

class KombuDaemon(threading.Thread):
  def __init__(self):
    threading.Thread.__init__(self)
    self.settings = ConfigParser.ConfigParser()
    self.settings.read('../config/site.ini')
    self.rabbitmqUsername = self.settings.get('rabbitmq', 'username')
    self.rabbitmqPassword = self.settings.get('rabbitmq', 'password')
    self.rabbitmqHost = self.settings.get('rabbitmq', 'host')
    self.rmqConn = Connection('amqp://'+self.rabbitmqUsername+':'+self.rabbitmqPassword+'@'+self.rabbitmqHost+':5672//')
  def run(self):


    def list_mac_addresses(message=None, args=None):
      rpcReply(entries, args)

    def rpcReply(message, req):
      #this is so retarded... stomp leaves the /temp-queue in the header... so we need to strip it off
      #or it won't get routed to the appropriate queue
      replyTo = re.search('\/.*\/(.*)', req.properties['reply_to']).group(1)
      rpcProducer.publish(body=message, **dict({'routing_key': replyTo,
                  'correlation_id': req.properties.get('correlation_id'),
                  'content_encoding': req.content_encoding}))
    operations = {
      "list_mac_addresses" : list_mac_addresses
    }

    def on_request(body, req):
      message = json.loads(body)
      print "Received message ",message
      sys.stdout.flush()
      operations[message['operation']](message, req)

    rpcProducer= Producer(self.rmqConn.channel(), serializer="json")

    queue = Queue(
      name="actiontec.cmd",
      exchange=Exchange('router.cmd'),
      channel=self.rmqConn.channel(),
      durable=False,
      exclusive=False,
      auto_delete=True)
    consumer = Consumer(self.rmqConn.channel(), queues = queue, auto_declare=True, callbacks=[on_request])
    consumer.consume(no_ack=True)


    while True:
      self.rmqConn.drain_events()

class ArpDiscoveryDaemon(threading.Thread):
  def __init__(self):
    threading.Thread.__init__(self)
    self.settings = ConfigParser.ConfigParser()
    self.settings.read('../config/site.ini')
    self.rabbitmqUsername = self.settings.get('rabbitmq', 'username')
    self.rabbitmqPassword = self.settings.get('rabbitmq', 'password')
    self.rabbitmqHost = self.settings.get('rabbitmq', 'host')
    self.rmqConn = Connection('amqp://'+self.rabbitmqUsername+':'+self.rabbitmqPassword+'@'+self.rabbitmqHost+':5672//')
    self.statusProducer = Producer(self.rmqConn.channel(), exchange = Exchange('router.status', type='fanout'), serializer="json")
    self.subnet = self.settings.get('actiontec', 'subnet')

  def run(self):
    ans,unans=srp(Ether(dst="ff:ff:ff:ff:ff:ff")/ARP(pdst=self.subnet),timeout=2)
    entries = []
    for snd,rcv in ans:
      hostname = ""
      ip = rcv.sprintf(r"%ARP.psrc%")
      mac = rcv.sprintf(r"%Ether.src%")
      secs  = 0
      try:
        if hasattr(socket, 'setdefaulttimeout'):
          socket.setdefaulttimeout(1)
        print "looking up host for",ip
        (hostname, aliaslist, ipaddrlist) = socket.gethostbyaddr(ip)
      except socket.herror:
        None
      entries.append({
        "hostname": hostname,
        "ip": ip,
        "mac": mac,
        "secs": secs
      })
    self.statusProducer.publish(body = entries)
#
# Executes if the program is started normally, not if imported
#
if __name__ == '__main__':
  rlock = threading.RLock()

  entries = []

  arpDiscoveryDaemon = ArpDiscoveryDaemon()
  arpDiscoveryDaemon.setDaemon(True)
  arpDiscoveryDaemon.start()

  kombuDaemon = KombuDaemon()
  kombuDaemon.setDaemon(True)
  kombuDaemon.start()

  while threading.active_count() > 0:
    time.sleep(0.1)
    if arpDiscoveryDaemon.isAlive() is not True or kombuDaemon.isAlive() is not True:
      sys.exit()