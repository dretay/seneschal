from scapy.all import srp,Ether,ARP,conf
from dns import resolver,reversename
import threading, json, time, ConfigParser, datetime, sys

class ArpDiscoveryDaemon(threading.Thread):
  def __init__(self, arpQueue):
    threading.Thread.__init__(self)
    self.settings = ConfigParser.ConfigParser()
    self.settings.read('../config/site.ini')
    self.subnet = self.settings.get('actiontec', 'subnet')
    self.entries = []
    self.arpQueue = arpQueue

  def run(self):
    while 1:
      ans,unans=srp(Ether(dst="ff:ff:ff:ff:ff:ff")/ARP(pdst=self.subnet),timeout=2)
      entries = []
      for snd,rcv in ans:
        ip = rcv.sprintf(r"%ARP.psrc%")
        mac = rcv.sprintf(r"%Ether.src%")
        hostname = ""
        try:
          addr=reversename.from_address(ip)
          hostname = str(resolver.query(addr,"PTR")[0])
        except resolver.NXDOMAIN:
          None
        entries.append({
          "hostname": hostname,
          "ip": ip,
          "mac": mac,
          "timestamp": int(time.mktime(datetime.datetime.now().timetuple()))
        })
      if len(entries)>0:
        print "Discovery complete, found",len(entries),"hosts"
        sys.stdout.flush()
        self.arpQueue.put(entries)
      time.sleep(60)