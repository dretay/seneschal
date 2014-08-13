from kombu import Connection, Producer, Exchange, Queue, Consumer, common as kombucommon
import threading, json, time, socket, signal, sys, requests, ConfigParser, re, xmlrpclib
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
  supervisorUsername = settings.get('supervisor', 'username')
  supervisorPassword = settings.get('supervisor', 'password')
  supervisorHost = settings.get('supervisor', 'host')
  supervisorPort = settings.get('supervisor', 'port')

  #setup rabbitmq connections
  rmqConn = Connection('amqp://'+rabbitmqUsername+':'+rabbitmqPassword+'@'+rabbitmqHost+':5672//')
  rpcProducer= Producer(rmqConn.channel(), serializer="json")
  statusProducer = Producer(rmqConn.channel(), exchange = Exchange('supervisor.status', type='fanout'), serializer="json")
  queue = Queue(
    name="supervisor.cmd",
    exchange=Exchange('system.cmd'),
    channel=rmqConn.channel(),
    durable=False,
    exclusive=False,
    auto_delete=True)

  #setup supervisor connection
  supervisorConn = xmlrpclib.Server("http://%s:%s@%s:%s/RPC2" % (supervisorUsername, quote(supervisorPassword.encode('utf-8')),supervisorHost, supervisorPort ))

  #setup message handlers
  def rpcReply(message, req):
  #this is so retarded... stomp leaves the /temp-queue in the header... so we need to strip it off
  #or it won't get routed to the appropriate queue
    replyTo = re.search('\/.*\/(.*)', req.properties['reply_to']).group(1)
    rpcProducer.publish(body=message, **dict({'routing_key': replyTo,
                'correlation_id': req.properties.get('correlation_id'),
                'content_encoding': req.content_encoding}))

  #individual task operations
  def task_start(message=None, args=None):
    processname = message['processname']
    result = supervisorConn.supervisor.startProcess(processname)
    rpcReply(result, args)
    list_processes()

  def task_stop(message=None, args=None):
    processname = message['processname']
    result = supervisorConn.supervisor.stopProcess(processname)
    rpcReply(result, args)
    list_processes()

  def task_restart(message=None, args=None):
    processname = message['processname']
    result = supervisorConn.system.multicall([
      {
        'methodName':'supervisor.stopProcess',
        'params': [processname]
      },
      {
        'methodName':'supervisor.startProcess',
        'params': [processname]
      }
    ])
    rpcReply(result, args)
    list_processes()

  def read_log(message=None, args=None):
    processname = message['processname']
    limit = message['limit']
    offset = 0
    limit = min(-1024, int(limit)*-1 if limit.isdigit() else -1024)
    result = supervisorConn.supervisor.readProcessStdoutLog(processname,-1024,0)
    rpcReply(result, args)

  #global supervisor operations
  def list_processes(message=None, args=None):
    result = supervisorConn.supervisor.getAllProcessInfo()
    statusProducer.publish(body = result)

  def task_stopall(message=None, args=None):
    result = supervisorConn.supervisor.stopAllProcesses()
    rpcReply(result, args)
  def task_restartall(message=None, args=None):
    result = supervisorConn.system.multicall([
      {'methodName':'supervisor.stopAllProcesses'},
      {'methodName':'supervisor.startAllProcesses'}
    ])
    rpcReply(result, args)

  def on_request(body, req):
    message = json.loads(body)
    print "Received message ",message
    sys.stdout.flush()
    operations = {
      "list_processes" : list_processes,
      "task_start" : task_start,
      "task_stop" : task_stop,
      "task_restart" : task_restart,
      "read_log" : read_log
    }
    operations[message['operation']](message, req)

  #lets light this candle
  consumer = Consumer(rmqConn.channel(), queues = queue, auto_declare=True, callbacks=[on_request])
  consumer.consume(no_ack=True)

  while True:
    rmqConn.drain_events()


