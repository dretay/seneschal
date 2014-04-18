#!/opt/local/bin/python2.7

import sys, os, time, thread
import ConfigParser
import glib, gobject
import pygst
import urllib
pygst.require("0.10")
import gst
import sys
import time

class IPCameraProxy(object):

    pipeline = None

    def __init__(self, pipeline):
        self.pipeline = gst.parse_launch(pipeline)

        bus = self.pipeline.get_bus()
        bus.add_signal_watch()
        bus.connect("message", self.on_message)

    def on_message(self, bus, message):
        t = message.type
        if t == gst.MESSAGE_EOS:
            self.pipeline.set_state(gst.STATE_NULL)
            sys.exit(1)

        elif t == gst.MESSAGE_ERROR:
            self.pipeline.set_state(gst.STATE_NULL)
            err, debug = message.parse_error()
            print "Error: %s" % err, debug
            sys.exit(1)

    def start(self):
        self.pipeline.set_state(gst.STATE_PLAYING)

    def stop(self):
        self.pipeline.set_state(gst.STATE_NULL)
        sys.exit(1)

def getPipeline(hostname, port, security_token, label):
  parameters = [
    'souphttpsrc do-timestamp=true location=%s%s is_live=true timeout=5',
    'multipartdemux',
    'jpegdec',
    'queue leaky=2 max-size-buffers=5',
    'ffmpegcolorspace',
    'clockoverlay text="%s - " halign=right valign=top time-format="%%Y/%%m/%%d %%H:%%M:%%S"',
    # 'tee name=videoTee \n videoTee. ! jpegenc ! queue leaky=2 max-size-buffers=10 ! multipartmux name=multipartMux boundary=spionisto ! tcpclientsink port=%s \n videoTee. ! queue max-size-buffers=50 ! videorate ! video/x-raw-rgb, framerate=1/5 ! jpegenc ! multifilesink location=/Volumes/Raid/security_camera_feeds/%s-%%05d.jpg'
    'jpegenc',
    'queue leaky=2 max-size-buffers=5',
    'multipartmux name=multipartMux boundary=spionisto',
    'tcpclientsink port=%s'
  ]
  return ' ! '.join(parameters) % (hostname, urllib.quote(security_token), label, port)
def load_configuration(filename):
    """
    Loads configuration. Just returns the port
    """
    config = ConfigParser.SafeConfigParser()
    config.read(filename)
    return config.get('spionisto', 'pipeline')

if __name__ == '__main__':
    label = sys.argv[1]
    hostname = sys.argv[2]
    port = sys.argv[3]
    token = sys.argv[4]
    time.sleep(5)

    pipeline = getPipeline(hostname, port, token, label)
    print 'complete gstreamer pipeline: %s'%(pipeline)
    sys.stdout.flush()
    proxy = IPCameraProxy(pipeline)
    thread.start_new_thread(proxy.start, ())
    gobject.threads_init()
    loop = glib.MainLoop()
    loop.run()
