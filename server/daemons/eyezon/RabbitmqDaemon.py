from kombu import Connection, Producer, Exchange, Consumer
import threading, Queue, kombu, socket, ConfigParser, re

class RabbitmqDaemon(threading.Thread):
  def __init__(self, cmd_q=None, reply_q=None):
    threading.Thread.__init__(self)
    self.settings = ConfigParser.ConfigParser()
    self.settings.read('../config/site.ini')
    self.rabbitmqUsername = self.settings.get('rabbitmq', 'username')
    self.rabbitmqPassword = self.settings.get('rabbitmq', 'password')
    self.rabbitmqHost = self.settings.get('rabbitmq', 'host')
    self.conn = Connection('amqp://'+self.rabbitmqUsername+':'+self.rabbitmqPassword+'@'+self.rabbitmqHost+':5672//')
    self.producer = Producer(self.conn.channel(), exchange = Exchange('eyezon.status', type='fanout'), serializer="json")
    self.rpcProducer= Producer(self.conn.channel(), serializer="json")

    self.cmd_q = cmd_q or Queue.Queue()
    self.reply_q = reply_q or Queue.Queue()

    queue = kombu.Queue(
        name="eyezon.cmd",
        exchange=Exchange('eyezon.cmd'),
        channel=self.conn.channel(),
        durable=False,
        exclusive=False,
        auto_delete=True)
    self.consumer = Consumer(self.conn.channel(), queues = queue, auto_declare=True, callbacks=[self.send_cmd])
    self.consumer.consume(no_ack=True)

    self.alarmCache = {
      "zoneTimerDump": None,
      "keypadUpdate": None,
      "zoneStateChange": None,
      "partitionStateChange": None,
      "realtimeCIDEvent": None,
      "zoneTimerDump": None
    }

  def send_cmd(self, message, req):
    msg = message.encode('utf-8')
    if msg == "^02,$" and self.alarmCache['zoneTimerDump'] != None:
      self.rpcReply(self.alarmCache['zoneTimerDump'], req)
    elif msg == "getKeypadStatus" and self.alarmCache['keypadUpdate'] != None:
      self.rpcReply(self.alarmCache['keypadUpdate'], req)

    if msg != "getKeypadStatus":
      self.cmd_q.put(msg)

  def rpcReply(self, message, req):
    self.rpcProducer.publish(body=message, **dict({'routing_key': req.properties['reply_to'],
                'correlation_id': req.properties.get('correlation_id'),
                'content_encoding': req.content_encoding}))


  def publishEvent(self, event):
    if event['name'] == "Zone Timer Dump":
      self.alarmCache["zoneTimerDump"] = event
    elif event['name'] == "Virtual Keypad Update":
      self.alarmCache["keypadUpdate"] = event
    elif event['name'] == "Zone State Change":
      self.alarmCache["zoneStateChange"] = event
    elif event['name'] == "Partition State Change":
      self.alarmCache["partitionStateChange"] = event
    elif event['name'] == "Realtime CID Event":
      self.alarmCache["realtimeCIDEvent"] = event
    elif event['name'] == "Zone Timer Dump":
      self.alarmCache["zoneTimerDump"] = event
    self.producer.publish(exchange = 'eyezon.status', routing_key = "", body = event)

  def run(self):
    while 1:
      try:
        cmd = self.reply_q.get(True, 0.1)
        self.publishEvent(cmd)

      except Queue.Empty as e:
        try:
          self.conn.drain_events(timeout=0.1)
        except socket.timeout:
          None

#main function
if __name__ == "__main__":
  rabbitmqDaemon = RabbitmqDaemon()
  rabbitmqDaemon.setDaemon(True)
  rabbitmqDaemon.start()
  while 1:
    None
