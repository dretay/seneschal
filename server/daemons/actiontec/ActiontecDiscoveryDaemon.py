from dns import resolver,reversename
from python_actiontec.actiontec.actiontec import Actiontec
import threading, json, time, ConfigParser, datetime, sys,os,netsnmp, re

class ActiontecDiscoveryDaemon(threading.Thread):
  def __init__(self, discoveryQueue):
    threading.Thread.__init__(self)
    self.settings = ConfigParser.ConfigParser()
    self.settings.read('../config/site.ini')
    self.actiontecPassword = self.settings.get('actiontec', 'password')
    self.entries = []
    self.discoveryQueue = discoveryQueue
    self.routerConn = Actiontec(password=self.actiontecPassword)


  def run(self):
    def dump_mac_addresses():
      result = self.routerConn.run('firewall mac_cache_dump')
      pattern = "@\d+\s+ip:\s+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s+mac:\s(\w+:\w+:\w+:\w+:\w+:\w+)\s+valid for:\s+(-?\d+)\ssec"

      regex = re.compile(pattern)
      entries = {}
      for match in regex.finditer(result):
        hostname = "Unknown"
        ip = match.group(1)
        mac = match.group(2)
        secs  = match.group(3)
        try:
          addr=reversename.from_address(ip)
          hostname = str(resolver.query(addr,"PTR")[0])
        except resolver.NXDOMAIN:
          None
        entries[mac.upper()] = {
          "hostname": hostname,
          "ip": ip,
          "secs": secs
        }
      print "Actiontec discovery finished; discovered",len(entries),"hosts"
      sys.stdout.flush()
      return entries
    while 1:
      self.discoveryQueue.put(dump_mac_addresses())
      time.sleep(60)
