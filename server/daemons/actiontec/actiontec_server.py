import threading, Queue, time, sys
from ArpDiscoveryDaemon import ArpDiscoveryDaemon
from RabbitmqDaemon import RabbitmqDaemon



#
# Executes if the program is started normally, not if imported
#
if __name__ == '__main__':
  rlock = threading.RLock()

  arpQueue = Queue.Queue()

  entries = []

  arpDiscoveryDaemon = ArpDiscoveryDaemon(arpQueue)
  arpDiscoveryDaemon.setDaemon(True)
  arpDiscoveryDaemon.start()

  rabbitmqDaemon = RabbitmqDaemon(arpQueue)
  rabbitmqDaemon.setDaemon(True)
  rabbitmqDaemon.start()

  while threading.active_count() > 0:
    time.sleep(0.1)
    if arpDiscoveryDaemon.isAlive() is not True or rabbitmqDaemon.isAlive() is not True:
      sys.exit()