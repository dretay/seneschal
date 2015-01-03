import threading, json, time, ConfigParser, datetime, sys,os,netsnmp, re

class TimecapsuleDiscoveryDaemon(threading.Thread):
  def __init__(self, discoveryQueue):
    threading.Thread.__init__(self)
    self.settings = ConfigParser.ConfigParser()
    self.settings.read('../config/site.ini')
    self.timecapsuleIp = self.settings.get('actiontec', 'timecapsuleIp')
    self.entries = []
    self.discoveryQueue = discoveryQueue


  def run(self):

    def tableToDict(table, num):
      table = list(table)
      clients = []
      clientTable = {}

      # First get the MACs
      i = num
      while i > 0:
          data = table.pop(0)
          clients.append(data)
          clientTable[data] = {}
          i = i - 1
      CMDS=['type', 'rates', 'time', 'lastrefresh', 'signal', 'noise', 'rate', 'rx',
        'tx', 'rxerr', 'txerr']
      for cmd in CMDS:
          i = 0
          while i < num:
              data = table.pop(0)
              clientTable[clients[i]][cmd] = data
              i = i + 1

      return clientTable
    def getNumClients(timecapsuleIp):
      wirelessNumberOID = '.1.3.6.1.4.1.63.501.3.2.1.0'
      return int(netsnmp.snmpget(netsnmp.Varbind(wirelessNumberOID),
        Version=2, DestHost=timecapsuleIp, Community='public')[0])

    def dump_client_table(timecapsuleIp):
      wirelessClientTableOID = '.1.3.6.1.4.1.63.501.3.2.2.1'

      numClients = getNumClients(timecapsuleIp)

      if numClients == 0:
          # FIXME: what's actually the correct munin plugin behaviour if there is no
          # data to be presented?
          sys.exit(0)

      clientTable = netsnmp.snmpwalk(netsnmp.Varbind(wirelessClientTableOID),
                                     Version=2, DestHost=timecapsuleIp,
                                     Community='public')
      clients = tableToDict(clientTable, numClients)
      print "Timecapsule discovery finished; discovered",len(clients),"hosts"
      sys.stdout.flush()

      return clients

    while 1:
      self.discoveryQueue.put(dump_client_table(self.timecapsuleIp))
      time.sleep(3)
