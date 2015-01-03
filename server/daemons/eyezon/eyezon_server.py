from EyezonDaemon import EyezonDaemon
from RabbitmqDaemon import RabbitmqDaemon
import Queue, threading, time, sys

#main function
if __name__ == "__main__":

  commandQueue = Queue.Queue()
  replyQueue = Queue.Queue()

  eyezonDaemon = EyezonDaemon("192.168.1.3", 4025, commandQueue, replyQueue)
  eyezonDaemon.setDaemon(True)
  eyezonDaemon.start()

  rabbitmqDaemon = RabbitmqDaemon(commandQueue, replyQueue)
  rabbitmqDaemon.setDaemon(True)
  rabbitmqDaemon.start()

  while threading.active_count() > 0:
    time.sleep(0.1)
    if eyezonDaemon.isAlive() is not True or eyezonDaemon.isAlive() is not True:
      sys.exit()