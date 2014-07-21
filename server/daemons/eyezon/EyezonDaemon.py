import socket, struct, threading, Queue, datetime, time, sys, ConfigParser

class EyezonDaemon(threading.Thread):
  def __init__(self, host=None, port=None, cmd_q=None, reply_q=None):
    threading.Thread.__init__(self)
    self.host = host or "192.168.1.10"
    self.port = port or 4025

    self.cmd_q = cmd_q or Queue.Queue()
    self.reply_q = reply_q or Queue.Queue()

    self.pendingZoneTimerDump = False
    self.settings = ConfigParser.ConfigParser()
    self.settings.read('../config/site.ini')


  def run(self):

    def requestZoneTimerDump():
      print "Requesting Zone Timer Dump"
      sys.stdout.flush()
      self.pendingZoneTimerDump = True
      alarmSocket.send("^02,$")


    def send_cmd(message):
        msg = message.encode('utf-8')

        if msg == "^02,$":
          requestZoneTimerDump()
        else:
          print "Sending command to alarm:", msg
          sys.stdout.flush()
          alarmSocket.send(msg+"\r\n")

    def publishEvent(event):
      self.reply_q.put(event)

    def partitionLabel(x):
      return {
          0: "Partition is not Used/Doesn't Exist",
          1: "Ready",
          2: "Ready to Arm (Zones are Bypasses)",
          3: "Not Ready",
          4: "Armed in Stay Mode",
          5: "Armed in Away Mode",
          6: "Armed Maximum (Zero Entry Delay)",
          7: "Exit Delay (not implemented on all platforms)",
          8: "Partition is in Alarm",
          9: "Alarm has occurred (Alarm in memory)",
      }[x]
    def processAlarmLogin():
      password = self.settings.get('eyezon', 'password')
      alarmSocket.send(password)
    def processKeypadUpdate(data):
      print "Processing Keypad Update"
      sys.stdout.flush()
      tokens = data[:-1].split(",")
      ledField = bin(int(tokens[2], 16))[2:].zfill(16)
      event={
        "name": "Virtual Keypad Update",
        "payload": {
          "partition": tokens[1],
          "leds":{
            "ARMED STAY": ledField[0] == "1",
            "LOW BATTERY": ledField[1] == "1",
            "FIRE": ledField[2] == "1",
            "READY": ledField[3] == "1",
            "CHECK ICON - SYSTEM TROUBLE": ledField[6] == "1",
            "ALARM (FIRE ZONE)": ledField[7] == "1",
            "ARMED (ZERO ENTRY DELAY)": ledField[8] == "1",
            "CHIME": ledField[10] == "1",
            "BYPASS (Zones are bypassed)": ledField[11] == "1",
            "AC PRESENT": ledField[12] == "1",
            "ARMED AWAY": ledField[13] == "1",
            "ALARM IN MEMORY": ledField[14] == "1",
            "ALARM (System is in Alarm)": ledField[15] == "1"
          },
          "beep": tokens[4],
          "message": tokens[5]
        }
      }
      publishEvent(event)


    def processZoneStateChange(data):
      print "Processing Zone State Change"
      sys.stdout.flush()
      data = data[4:len(data)-1]
      counter = 0
      zonesBuffer = []
      for i in xrange(0, len(data), 4):
        zones = bin(int((data[i:i+4]).decode("hex")[::-1].encode("hex"), 16))[2:].zfill(16)[::-1]
        for zone in xrange(0, len(zones), 1):
          zonesBuffer.append({
            "name": "Zone " + str(counter),
            "status": zones[zone]
          })
          counter +=1
      event = {
        "name": "Zone State Change",
        "payload":{
          "zones": zonesBuffer
        }
      }
      publishEvent(event)

    def processPartitionStateChange(data):
      print "Processing Partition State Change"
      sys.stdout.flush()
      data = data[4:len(data)-1]
      partitions = []
      partitionReady = False
      for i in xrange(0, len(data), 4):
          partition = i/4
          status = partitionLabel(int((data[i:i+4]).decode("hex")[::-1].encode("hex"), 16))
          if status == "Ready": partitionReady = True
          partitions.append({
            "partition": partition,
            "status": status
          })
      event = {
        "name": "Partition State Change",
        "payload":{
          "partitions": partitions
        }
      }
      publishEvent(event)
      if partitionReady == False: requestZoneTimerDump()

    def processRealtimeCIDEvent(data):
      print "Processing Realtime CID Event"
      sys.stdout.flush()
      data = data[4:len(data)-1]
      event = {
        "name": "Realtime CID Event",
        "payload": {
          "qualifier": "Event" if data[0:1] == 1 else "Restoral",
          "contact id": data[1:4],
          "partition": data[4:6],
          "zone or user": data[6:9]
        }
      }
      publishEvent(event)


    def processZoneTimerDump(data):
      print "Processing Zone Timer Dump"
      sys.stdout.flush()
      data = data[4:len(data)-1]
      timers = []
      for i in xrange(0, (len(data)), 4):
        timerDelta =  (int("FFFF",16) - int((data[i:i+4]).decode("hex")[::-1].encode("hex"), 16))*5
        timers.append({
          "zone": i/4,
          "timestamp":  time.mktime((datetime.datetime.now() - datetime.timedelta(seconds=timerDelta)).timetuple())*1000,
          "delta": timerDelta
        })
      event = {
        "name": "Zone Timer Dump",
        "payload":{
          "timers": timers
        }
      }

      publishEvent(event)
      self.pendingZoneTimerDump = False

    def processUnhandledAlarmEvent(data):
      print "!!!!!!!!!!!UNHANDLED / UNKNOWN ALARM EVENT !!!!!!!!!!!!!!!!!"
      print data
      print "!!!!!!!!!!!UNHANDLED / UNKNOWN ALARM EVENT !!!!!!!!!!!!!!!!!"
      sys.stdout.flush()
    alarmProcessors = {
      "%00" : processKeypadUpdate,
      "%01" : processZoneStateChange,
      "%02" : processPartitionStateChange,
      "%03" : processRealtimeCIDEvent,
      "%FF" : processZoneTimerDump
    }


    alarmSocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    alarmSocket.settimeout(1)
    # connect to remote host
    try :
        alarmSocket.connect((self.host, self.port))
    except :
        print 'Unable to connect'
        sys.stdout.flush()
        sys.exit()

    while 1:

      try:
        rawData = alarmSocket.recv(4096).strip()
        if not rawData :
          print '\nDisconnected from alarm server'
          sys.stdout.flush()
          sys.exit()
        else:
          for data in rawData.split("\n"):
            data = data.strip()

            #handler for seeing data we're sending over the wire
            if data[0:1] == "^":
              break

            # handler for data from the alarm
            elif data[0:1] == "%":
              command = data[0:3]
              if command in alarmProcessors:
                alarmProcessors[data[0:3]](data)
              else:
                processUnhandledAlarmEvent(data)

            #special case handlers
            else:
              if data[0:6] == "Login:":
                processAlarmLogin()
              elif data[0:2] != "OK":
                processUnhandledAlarmEvent(data)
      except socket.error as e:
        if e != "timed out":
          try:
            # Queue.get with timeout to allow checking self.alive
            cmd = self.cmd_q.get(True, 0.1)
            send_cmd(cmd)
          except Queue.Empty as e:
            None
        else:
          print "EYEZON Unhandled error", e
          sys.stdout.flush()
          sys.exit()

#main function
if __name__ == "__main__":
  eyezonDaemon = EyezonDaemon()
  eyezonDaemon.setDaemon(True)
  eyezonDaemon.start()
  while 1:
    None
