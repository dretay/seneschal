from kombu import Connection, Producer, Exchange, Queue, Consumer, common as kombucommon
import json, sys, ConfigParser, re, socket, subprocess, time

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
  rmqChannel = rmqConn.channel()

  # descriptions =
  #    'Processes':
  #      'r': 'Number of processes waiting for run time'
  #      'b': 'Number of processes in uninterruptible sleep'

  #    'Memory':
  #      'swpd': 'Amount of virtual memory used'
  #      'free': 'Amount of idle memory'
  #      'buff': 'Amount of memory used as buffers'
  #      'cache': 'Amount of memory used as cache'

  #    'Swap':
  #      'si': 'Amount of memory swapped in from disk'
  #      'so': 'Amount of memory swapped to disk'

  #    'IO':
  #      'bi': 'Blocks received from a block device (blocks/s)'
  #      'bo': 'Blocks sent to a block device (blocks/s)'

  #    'System':
  #      'in': 'Number of interrupts per second, including the clock',
  #      'cs': 'Number of context switches per second'

  #    'CPU':
  #      'us': 'Time spent running non-kernel code (user time, including nice time)'
  #      'sy': 'Time spent running kernel code (system time)'
  #      'id': 'Time spent idle'
  #      'wa': 'Time spent waiting for IO'

  processesStatusProducer = Producer(rmqChannel, exchange = Exchange('system.status.processes', type='fanout'), serializer="json")
  memoryStatusProducer = Producer(rmqChannel, exchange = Exchange('system.status.memory', type='fanout'), serializer="json")
  swapStatusProducer = Producer(rmqChannel, exchange = Exchange('system.status.swap', type='fanout'), serializer="json")
  ioStatusProducer = Producer(rmqChannel, exchange = Exchange('system.status.io', type='fanout'), serializer="json")
  systemStatusProducer = Producer(rmqChannel, exchange = Exchange('system.status.system', type='fanout'), serializer="json")
  cpuStatusProducer = Producer(rmqChannel, exchange = Exchange('system.status.cpu', type='fanout'), serializer="json")

  #global supervisor operations
  def get_sys_status(message=None, args=None):
    result = subprocess.check_output(["/usr/bin/vmstat","-n","1","2"]).split("\n")[3]
    result = re.findall('\d+',result)
    processesStatusProducer.publish(body=[result[0], result[1]])
    memoryStatusProducer.publish(body=[result[2], result[3], result[4], result[5]])
    swapStatusProducer.publish(body=[result[6], result[7]])
    ioStatusProducer.publish(body=[result[8], result[9]])
    systemStatusProducer.publish(body=[result[10], result[11]])
    cpuStatusProducer.publish(body=[result[12], result[13], result[14], result[15]])


  while True:
    get_sys_status()
    time.sleep(2)

