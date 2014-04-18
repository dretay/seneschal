import ConfigParser
import os
import xmlrpclib
import tempfile
import pprint
import sys

from SimpleXMLRPCServer import SimpleXMLRPCServer
from os.path import (
    dirname,
    join,
    abspath
)


MJPEG_PORT_BASE = 9100
TCP_PORT_BASE = 9200

if __name__ == '__main__':
  scripts_dir = join(dirname(abspath(__file__)), 'scripts')
  cam_script = join(scripts_dir, 'ip-camera.py')
  proxy_script = join(scripts_dir, 'gst-proxy.py')
  config_dir = tempfile.mkdtemp(prefix='spionisto')
  s_api = xmlrpclib.ServerProxy('http://admin:admin@localhost:9001')
  security_token = "Z2/ih/sqp1eQeV6CpF+p+YxfRSMC5kDAm/P8Nr5/AnMuOPJ+hb1ItaHwufivSf7SjVVTi4N4orkCgR/L8C5rPRqen7oEeQDu2NP8CIx834jwv+AmgGQMIi6Nd/r0oajMSWP2sxleNni3oGhxC3JrKVym4Dtl4qV4NK9J+eGMMGt/rD8q9Pp5uhQA2Dw+1oY+"
  cameras = (
    {
    "id": 0,
    "hostname": "https://www.drewandtrish.com:9000/cameras/192.168.1.16/8082/videostream.cgi?rate=11&token=",
    "label": "Family Room"
    },
    {
    "id": 1,
    "hostname": "https://www.drewandtrish.com:9000/cameras/192.168.1.15/8081/videostream.cgi?rate=11&token=",
    "label": "Basement"
    },
    {
    "id": 2,
    "hostname": "https://www.drewandtrish.com:9000/cameras/192.168.1.17/8080/videostream.cgi?rate=11&token=",
    "label": "Front Door"
    },
    {
    "id": 3,
    "hostname": "https://www.drewandtrish.com:9000/cameras/192.168.1.18/8083/videostream.cgi?rate=11&token=",
    "label": "Porch"
    }
  )
  for camera in cameras:
    #Get pipeline and ports
    port_http = MJPEG_PORT_BASE + camera['id']
    port_tcp = TCP_PORT_BASE + camera['id']

    #Use supervisor's twiddler API to launch the proxy and the ipcamera
    print 'launching camera web server: %s %s %s'%(cam_script, port_http, port_tcp)
    s_api.twiddler.addProgramToGroup(
        'dynamic',
        'cam_script_%i' % camera['id'],
        {'command':'%s %s %s'%(cam_script, port_http, port_tcp),
         'autostart':'true',
         'autorestart':'false', 'startsecs':'0'}
    )
    print 'launching camera receiver: %s %s %s %s'%(proxy_script, camera['hostname'], TCP_PORT_BASE + camera['id'], security_token)
    s_api.twiddler.addProgramToGroup(
        'dynamic',
        'proxy_script_%i' % camera['id'],
        {'command':'%s "%s" %s %s %s'%(proxy_script, camera['label'], camera['hostname'], TCP_PORT_BASE + camera['id'], security_token),
         'autostart':'true',
         'autorestart':'true', 'startsecs':'2', 'startretries':'10'}
    )
    sys.stdout.flush()
