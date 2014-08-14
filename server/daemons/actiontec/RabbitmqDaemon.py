from kombu import Connection, Producer, Exchange, Consumer, common as kombucommon
import threading, json, time,  sys, ConfigParser, re, socket, Queue, kombu, socket

class RabbitmqDaemon(threading.Thread):
  def __init__(self, arpQueue):
    threading.Thread.__init__(self)
    self.settings = ConfigParser.ConfigParser()
    self.settings.read('../config/site.ini')
    self.rabbitmqUsername = self.settings.get('rabbitmq', 'username')
    self.rabbitmqPassword = self.settings.get('rabbitmq', 'password')
    self.rabbitmqHost = self.settings.get('rabbitmq', 'host')
    self.rmqConn = Connection('amqp://'+self.rabbitmqUsername+':'+self.rabbitmqPassword+'@'+self.rabbitmqHost+':5672//')
    self.statusProducer = Producer(self.rmqConn.channel(), exchange = Exchange('router.status', type='fanout'), serializer="json")
    self.entries = {}
    self.arpQueue = arpQueue

  def run(self):
    def list_mac_addresses(message=None, args=None):
      print "RPC reply with cached addresses ", len(self.entries)
      sys.stdout.flush()
      rpcReply(self.entries, args)

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

    queue = kombu.Queue(
      name="actiontec.cmd",
      exchange=Exchange('router.cmd'),
      channel=self.rmqConn.channel(),
      durable=False,
      exclusive=False,
      auto_delete=True)
    consumer = Consumer(self.rmqConn.channel(), queues = queue, auto_declare=True, callbacks=[on_request])
    consumer.consume(no_ack=True)

    while 1:
      try:
        newEntries = self.arpQueue.get(True, 0.1)
        for entry in newEntries:
          self.entries[entry["mac"]] = entry
        print "received",len(self.entries),"hosts from watcher"
        self.statusProducer.publish(body = self.entries)
      except:
        try:
          self.rmqConn.drain_events(timeout=0.1)
        except:
          None