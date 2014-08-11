import sys, logging, time, random
from HomeRouter import HomeRouter
from HomeAlarm import HomeAlarm
from intellect.Intellect import Intellect

class MyIntellect(Intellect):
    pass

if __name__ == '__main__':
  # tune down logging inside Intellect
  logger = logging.getLogger('intellect')
  logger.setLevel(logging.ERROR)
  consoleHandler = logging.StreamHandler(stream=sys.stdout)
  consoleHandler.setFormatter(logging.Formatter('%(asctime)s %(name)-12s %(levelname)-8s%(message)s'))
  logger.addHandler(consoleHandler)

  # set up logging for seneschal
  logger = logging.getLogger('seneschal')
  logger.setLevel(logging.DEBUG)
  consoleHandler = logging.StreamHandler(stream=sys.stdout)
  consoleHandler.setFormatter(logging.Formatter('%(asctime)s %(name)-12s %(levelname)-8s%(message)s'))
  logger.addHandler(consoleHandler)

  logging.getLogger("seneschal").debug("Creating reasoning engine.")
  myIntellect = MyIntellect()

  logging.getLogger("seneschal").debug("Asking the engine to learn my policy.")
  policy = myIntellect.learn(myIntellect.local_file_uri("./rulesets/seneschal.policy"))

  myIntellect.learn(HomeRouter())
  myIntellect.learn(HomeAlarm())
  myIntellect.reason()
  while True:
    logging.getLogger("seneschal").debug("{0} in knowledge.".format(myIntellect.knowledge))
    time.sleep(5)
    logging.getLogger("seneschal").debug("Messaging reasoning engine to reason.")
    myIntellect.reason()