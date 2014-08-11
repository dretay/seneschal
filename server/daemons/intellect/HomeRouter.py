from kombu import Connection, Producer, Exchange, Queue, Consumer, common as kombucommon
from threading import Lock
import json, sys, ConfigParser, re, socket, logging, threading


class MessagingDaemon(threading.Thread):
  def __init__(self, homeRouter):
    threading.Thread.__init__(self)
    settings = ConfigParser.ConfigParser()
    settings.read('../config/site.ini')
    rabbitmqUsername = settings.get('rabbitmq', 'username')
    rabbitmqPassword = settings.get('rabbitmq', 'password')
    rabbitmqHost = settings.get('rabbitmq', 'host')

    self.homeRouter = homeRouter
    self.rmqConn = Connection('amqp://'+rabbitmqUsername+':'+rabbitmqPassword+'@'+rabbitmqHost+':5672//')

    self.queue = Queue(
      exchange=Exchange('router.status', type='fanout'),
      channel=self.rmqConn.channel(),
      durable=False,
      exclusive=False,
      auto_delete=True)
    self.consumer = Consumer(self.rmqConn.channel(), queues = self.queue, auto_declare=True, callbacks=[self.on_request])
    self.consumer.consume()
  def on_request(self, body, req):
    # print body
    logging.getLogger("seneschal").debug("HomeRouter: updating mac timeout list")
    for device in body:
      self.homeRouter.connected_hosts.update({device['mac']: int(device['secs'])})
  def run(self):
    while True:
      try:
        self.rmqConn.drain_events()
      except socket.timeout:
        None


class HomeRouter:
  def __init__(self):
    '''
    HomeRouter Initializer
    '''
    logging.getLogger("seneschal").debug("HomeRouter: initialized")
    self.connected_hosts = {}

    self.lock = Lock()
    messagingDaemon = MessagingDaemon(self)
    messagingDaemon.setDaemon(True)
    messagingDaemon.start()
    # thread.start_new_thread(listen_for_router_status, (self,))


  @property
  def someone_is_home(self):
    return self.connected_hosts.get("98:b8:e3:8e:c3:e4") > -1000 or self.connected_hosts.get("68:96:7b:c1:16:99") > -1000

  @property
  def connected_hosts(self):
    return self._connected_hosts

  @connected_hosts.setter
  def connected_hosts(self, value):
      self.lock.acquire()
      self._connected_hosts = value
      self.lock.release()
if __name__ == '__main__':
  logger = logging.getLogger('seneschal')
  logger.setLevel(logging.DEBUG)
  consoleHandler = logging.StreamHandler(stream=sys.stdout)
  consoleHandler.setFormatter(logging.Formatter('%(asctime)s %(name)-12s %(levelname)-8s%(message)s'))
  logger.addHandler(consoleHandler)
  homeRouter = HomeRouter()

  while True:
      None