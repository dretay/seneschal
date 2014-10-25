import threading, Queue, time, sys
# from ActiontecDiscoveryDaemon import ActiontecDiscoveryDaemon
from RabbitmqDaemon import RabbitmqDaemon
from TimecapsuleDiscoveryDaemon import TimecapsuleDiscoveryDaemon



#
# Executes if the program is started normally, not if imported
#
if __name__ == '__main__':
  rlock = threading.RLock()

  timecapsuleQueue = Queue.Queue()

  entries = []

  # actiontecDiscoveryDaemon = ActiontecDiscoveryDaemon(actiontecQueue)
  # actiontecDiscoveryDaemon.setDaemon(True)
  # actiontecDiscoveryDaemon.start()

  timecapsuleDiscoveryDaemon = TimecapsuleDiscoveryDaemon(timecapsuleQueue)
  timecapsuleDiscoveryDaemon.setDaemon(True)
  timecapsuleDiscoveryDaemon.start()

  rabbitmqDaemon = RabbitmqDaemon(timecapsuleQueue)
  rabbitmqDaemon.setDaemon(True)
  rabbitmqDaemon.start()

  while threading.active_count() > 0:
    time.sleep(0.1)
    if rabbitmqDaemon.isAlive() is not True or timecapsuleDiscoveryDaemon.isAlive() is not True:
      sys.exit()