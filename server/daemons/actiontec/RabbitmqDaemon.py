from kombu import Connection, Producer, Exchange, Consumer, common as kombucommon
import threading, json, time,  sys, ConfigParser, re, socket, Queue, kombu, socket, datetime

class RabbitmqDaemon(threading.Thread):
  def __init__(self, actiontecQueue, timecapsuleQueue):
    threading.Thread.__init__(self)
    self.settings = ConfigParser.ConfigParser()
    self.settings.read('../config/site.ini')
    self.rabbitmqUsername = self.settings.get('rabbitmq', 'username')
    self.rabbitmqPassword = self.settings.get('rabbitmq', 'password')
    self.rabbitmqHost = self.settings.get('rabbitmq', 'host')
    self.rmqConn = Connection('amqp://'+self.rabbitmqUsername+':'+self.rabbitmqPassword+'@'+self.rabbitmqHost+':5672//')
    self.statusProducer = Producer(self.rmqConn.channel(), exchange = Exchange('router.status', type='fanout'), serializer="json")
    self.actiontecEntries = {}
    self.timecapsuleEntries = {}
    self.discoveredHosts = {}
    self.actiontecQueue = actiontecQueue
    self.timecapsuleQueue = timecapsuleQueue

  def run(self):
    def list_mac_addresses(message=None, args=None):
      print "RPC reply with",len(self.discoveredHosts)," cached addresses"
      sys.stdout.flush()
      rpcReply(self.discoveredHosts, args)

    def rpcReply(message, req):
      rpcProducer.publish(body=message, **dict({'routing_key': req.properties['reply_to'],
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
        actiontecEntries = self.actiontecQueue.get(True, 0.1)
        for mac,details in actiontecEntries.iteritems():
          if mac in self.actiontecEntries:
            if details["hostname"] != "":
              if self.actiontecEntries[mac]["hostname"] == "":
                print "Found missing hostname",details["hostname"],"for",mac
              self.actiontecEntries["hostname"] = details["hostname"]

            self.actiontecEntries[mac]["ip"] = details["ip"]
            self.actiontecEntries[mac]["secs"] = details["secs"]
          else:
            self.actiontecEntries[mac] = details
        print "Actiontec cache now contains",len(actiontecEntries),"entries"

      except Queue.Empty as e:
        try:
          self.timecapsuleEntries = self.timecapsuleQueue.get(True, 0.1)
          # newEntries = self.arpQueue.get(True, 0.1)
          # for entry in newEntries:
          #   self.entries[entry["mac"]] = entry
          # print "received",len(self.entries),"hosts from watcher"
          oldDiscoveredHosts = self.discoveredHosts
          self.discoveredHosts = {}
          for mac,details in self.timecapsuleEntries.iteritems():

            hostname = ""
            ip = ""
            tx = 0
            rx = 0
            txerr = 0
            rxerr = 0

            if mac in self.actiontecEntries:
              hostname = self.actiontecEntries[mac]["hostname"]
              ip = self.actiontecEntries[mac]["ip"]

            if mac in oldDiscoveredHosts:
              now = time.mktime((datetime.datetime.now()).timetuple())
              timeDelta = now - oldDiscoveredHosts[mac]["stats"]["timestamp"]

              rxDelta = int(details["rx"]) - oldDiscoveredHosts[mac]["rawStats"]["rx"]
              txDelta = int(details["tx"]) - oldDiscoveredHosts[mac]["rawStats"]["tx"]
              rxerrDelta = int(details["rxerr"]) - oldDiscoveredHosts[mac]["rawStats"]["rxerr"]
              txerrDelta = int(details["txerr"]) - oldDiscoveredHosts[mac]["rawStats"]["txerr"]

              tx = int(txDelta // timeDelta)
              rx = int(rxDelta // timeDelta)
              rxerr = int(rxerrDelta // timeDelta)
              txerr = int(txerrDelta // timeDelta)



            self.discoveredHosts[mac] = {
              "hostname": hostname,
              "ip": ip,
              "mac": mac,
              "rate": details['rate'],
              "stats":{
                "tx":tx,
                "rx":rx,
                "txerr":txerr,
                "rxerr":rxerr,
                "signal":int(details['signal']),
                "noise": int(details['noise']),
                "timestamp": time.mktime((datetime.datetime.now()).timetuple()),
              },
              "rawStats":{
                "tx": details['tx'],
                "rx": details['rx'],
                "rates": details['rates'],
                "time": int(details['time']),
                "noise": int(details['noise']),
                "rate": int(details['rate']),
                "rx": int(details['rx']),
                "tx": int(details['tx']),
                "rxerr": int(details['rxerr']),
                "txerr": int(details['txerr'])
              }
            }
          reply = []
          for mac,details in self.discoveredHosts.iteritems():
            reply.append({
              "hostname":details["hostname"],
              "ip":details["ip"],
              "mac":details["mac"],
              "rate":details["rate"],
              "stats":details["stats"]
              })
          self.statusProducer.publish(body = reply)
        except Queue.Empty as e:
          try:
            self.rmqConn.drain_events(timeout=0.1)
          except:
            None
