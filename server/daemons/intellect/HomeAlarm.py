from kombu import Connection, Producer, Exchange, Queue, Consumer, common as kombucommon
from threading import Lock
import json, sys, ConfigParser, re, socket, logging, threading


class MessagingDaemon(threading.Thread):
  def __init__(self, homeAlarm):
    threading.Thread.__init__(self)
    settings = ConfigParser.ConfigParser()
    settings.read('../config/site.ini')
    rabbitmqUsername = settings.get('rabbitmq', 'username')
    rabbitmqPassword = settings.get('rabbitmq', 'password')
    rabbitmqHost = settings.get('rabbitmq', 'host')

    self.homeAlarm = homeAlarm
    self.rmqConn = Connection('amqp://'+rabbitmqUsername+':'+rabbitmqPassword+'@'+rabbitmqHost+':5672//')

    self.queue = Queue(
      exchange=Exchange('alarm.status', type='fanout'),
      channel=self.rmqConn.channel(),
      durable=False,
      exclusive=False,
      auto_delete=True)
    self.consumer = Consumer(self.rmqConn.channel(), queues = self.queue, auto_declare=True, callbacks=[self.on_request])
    self.consumer.consume()

  def on_request(self, body, req):
    # print body
    if body['name'] == "Virtual Keypad Update":
      leds = body['payload']['leds']
      if leds['ARMED STAY'] or leds['ARMED (ZERO ENTRY DELAY)'] or leds['ARMED AWAY']:
        self.homeAlarm.armed = True
        logging.getLogger("seneschal").debug("HomeAlarm: alarm is armed")
      else:
        self.homeAlarm.armed = False
        logging.getLogger("seneschal").debug("HomeAlarm: alarm is NOT armed")


  def run(self):
    while True:
      try:
        self.rmqConn.drain_events()
      except socket.timeout:
        None


class HomeAlarm:
  def __init__(self):
    '''
    HomeAlarm Initializer
    '''
    logging.getLogger("seneschal").debug("HomeAlarm: initialized")
    self.armed = False

    self.lock = Lock()
    messagingDaemon = MessagingDaemon(self)
    messagingDaemon.setDaemon(True)
    messagingDaemon.start()

    settings = ConfigParser.ConfigParser()
    settings.read('../config/site.ini')
    rabbitmqUsername = settings.get('rabbitmq', 'username')
    rabbitmqPassword = settings.get('rabbitmq', 'password')
    rabbitmqHost = settings.get('rabbitmq', 'host')
    self.rmqConn = Connection('amqp://'+rabbitmqUsername+':'+rabbitmqPassword+'@'+rabbitmqHost+':5672//')
    self.producer = Producer(self.rmqConn.channel(), exchange = Exchange('alarm.cmd'), serializer="json")


  def should_arm_alarm(self, anyone_home):
    return anyone_home is not None and not anyone_home and not self.armed

  def arm_alarm(self):
    self.producer.publish(body = "#3")

  @property
  def armed(self):
    return self._armed

  @armed.setter
  def armed(self, value):
      self.lock.acquire()
      self._armed = value
      self.lock.release()
if __name__ == '__main__':
  logger = logging.getLogger('seneschal')
  logger.setLevel(logging.DEBUG)
  consoleHandler = logging.StreamHandler(stream=sys.stdout)
  consoleHandler.setFormatter(logging.Formatter('%(asctime)s %(name)-12s %(levelname)-8s%(message)s'))
  logger.addHandler(consoleHandler)
  homeAlarm = HomeAlarm()

  while True:
      None