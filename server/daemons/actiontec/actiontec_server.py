from python_actiontec.actiontec.actiontec import Actiontec
from kombu import Connection, Producer, Exchange, Queue, Consumer, common as kombucommon
import json, sys, ConfigParser, re, socket

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

  actiontecPassword = settings.get('actiontec', 'password')

  #setup rabbitmq connections
  rmqConn = Connection('amqp://'+rabbitmqUsername+':'+rabbitmqPassword+'@'+rabbitmqHost+':5672//')
  rpcProducer= Producer(rmqConn.channel(), serializer="json")
  statusProducer = Producer(rmqConn.channel(), exchange = Exchange('router.status', type='fanout'), serializer="json")
  queue = Queue(
    name="actiontec.cmd",
    exchange=Exchange('router.cmd'),
    channel=rmqConn.channel(),
    durable=False,
    exclusive=False,
    auto_delete=True)

  #setup router connection
  routerConn = Actiontec(password=actiontecPassword)

  #setup message handlers
  def rpcReply(message, req):
  #this is so retarded... stomp leaves the /temp-queue in the header... so we need to strip it off
  #or it won't get routed to the appropriate queue
    replyTo = re.search('\/.*\/(.*)', req.properties['reply_to']).group(1)
    rpcProducer.publish(body=message, **dict({'routing_key': replyTo,
                'correlation_id': req.properties.get('correlation_id'),
                'content_encoding': req.content_encoding}))


  #global supervisor operations
  def list_mac_addresses(message=None, args=None):
    result = routerConn.run('firewall mac_cache_dump')
    pattern = "@\d\s+ip:\s+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s+mac:\s(\w+:\w+:\w+:\w+:\w+:\w+)\s+valid for:\s+(-?\d+)\ssec"

    regex = re.compile(pattern)
    entries = []
    for match in regex.finditer(result):
      entries.append({
        "ip": match.group(1),
        "mac": match.group(2),
        "secs": match.group(3)
      })

    statusProducer.publish(body = entries)

  def on_request(body, req):
    message = json.loads(body)
    print "Received message ",message
    sys.stdout.flush()
    operations = {
      "list_mac_addresses" : list_mac_addresses
    }
    operations[message['operation']](message, req)

  #lets light this candle
  consumer = Consumer(rmqConn.channel(), queues = queue, auto_declare=True, callbacks=[on_request])
  consumer.consume(no_ack=False)

  while True:
    try:
      rmqConn.drain_events(timeout=5)
    except socket.timeout:
      list_mac_addresses()