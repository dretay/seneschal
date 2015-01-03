#!/usr/bin/python
#  -*- coding: UTF-8 -*-
# vim: set fileencoding=UTF-8 :

# Helper functions for parsing the dhcpd log

def parse_lease_file(lease_file, sorted = None):
  """
  Parse the DHCP lease file and returns active hosts
  @returns:
    list of dicts with
      {'ip':    <ip>,
       'mac':   <mac>,
       'start': <start>,
       'end':   <end>,
      }
  """
  import re, sys
  import datetime, time
  # lease 10.4.154.93 {
  #   starts 4 2008/12/04 10:07:00;
  #   ends 4 2008/12/04 22:07:00;
  #   tstp 4 2008/12/04 22:07:00;
  #   binding state free;
  #   hardware ethernet 00:0d:60:2f:2e:fd;
  #   uid "\001\000\015`/.\375";
  # }
  
  # important:
  #   strip newline
  #   delimiter := "}"
  lease = re.compile(r""".*
  lease\ (?P<ip>\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}).*
\ \ starts\ \d\ (?P<starts>\d{4}/\d{2}/\d{2}\ \d{2}:\d{2}:\d{2});.*
\ \ ends\ \d\ (?P<ends>\d{4}/\d{2}/\d{2}\ \d{2}:\d{2}:\d{2});.*
\ \ binding\ state\ (?P<bstate>\w+);.*
\ \ hardware\ ethernet\ (?P<mac>([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2});.*
  .*""", re.VERBOSE)
  
  fd = open(lease_file, "r")
  text = fd.read()
  fd.close()
  
  text = text.replace('\n','')
  textl = text.split('}')
  
  ll = {}
  for i in textl:
    if lease.match(i):
      ip = lease.match(i).group('ip')
      #if not ll.has_key(ip):
      # convert time to local time (in dhcp log is UTC)
      # timezone beachtet nicht daylight saving time ...
      start = ( datetime.datetime.strptime( lease.match(i).group('starts'), "%Y/%m/%d %H:%M:%S" ) \
                + datetime.timedelta( 0, time.altzone ) ).strftime("%Y/%m/%d %H:%M:%S") 
      end   = ( datetime.datetime.strptime( lease.match(i).group('ends'), "%Y/%m/%d %H:%M:%S" ) \
                + datetime.timedelta( 0, time.altzone ) ).strftime("%Y/%m/%d %H:%M:%S")
      ll[ip] = { 'mac':    lease.match(i).group('mac'),
                 'bstate': lease.match(i).group('bstate'),
                 'start':  start,
                 'end':    end,
               }
  if sorted == 'ip':
    return ll
  else:
    # return list
    lln = []
    for ip in ll.keys():
      tmp = ll[ ip ]
      tmp['ip'] = ip
      lln.append( tmp )
    return lln

