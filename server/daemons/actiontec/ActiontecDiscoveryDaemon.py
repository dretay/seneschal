from actiontec.connection import ActionTec
from actiontec.cmd import cmd_conf
import actiontec.confparser as confparser
import threading, time, ConfigParser, re

class ActiontecDiscoveryDaemon(threading.Thread):
  def __init__(self, discoveryQueue):
    threading.Thread.__init__(self)
    self.settings = ConfigParser.ConfigParser()
    self.settings.read('../config/site.ini')
    self.actiontecPassword = self.settings.get('actiontec', 'password')
    self.entries = []
    self.discoveryQueue = discoveryQueue
    self.routerConn = ActionTec('192.168.1.1', 'admin', 'peanut')
    self.routerConn.connect()


  def run(self):
    def dump_mac_addresses():
      res,out = at.run("conf print dev/br0/dhcps/lease")
      parser = confparser.Parser()
      foo = parser.parse(out)
      entries = {}
      for property,value in foo['lease'].iteritems():
        if value.has_key('hardware_mac'):
          entries[value['hardware_mac']] = {
            "hostname": value['hostname'],
            "ip": value['ip'],
          }

      print "Actiontec discovery finished; discovered",len(entries),"hosts"
      sys.stdout.flush()
      return entries
    while 1:
      self.discoveryQueue.put(dump_mac_addresses())
      time.sleep(60)
