import pika
import logging
from ouimeaux.environment import Environment
import json

logging.basicConfig()
credentials = pika.PlainCredentials('backendclient','WwTMfbtzxGNGhte0kxao')
connection = pika.BlockingConnection(pika.ConnectionParameters(
        host='galactica.local', credentials = credentials))
channel = connection.channel()

channel.queue_declare(queue='wemo.lights',
                      durable=False,
                      exclusive=False,
                      auto_delete=True)
NOOP = lambda *x: None

def on_switch(switch):
	print "Switch found!", switch.name
def on_motion(motion):
	print "Motion found!", motion.name
global env
env = Environment(on_switch, on_motion, with_cache=False)
env.start()
env.discover(seconds=10)

def toggle_on(message, args):
  print "Turning "+message['switchName']+" on..."
  switch = env.get_switch(message['switchName'])
  rpcReply(switch.on(), args)

def toggle_off(message, args):
  print "Turning "+message['switchName']+" off..."
  switch = env.get_switch(message['switchName'])
  rpcReply(switch.off(), args)

def status(message, args):
  print "Getting status for "+message['switchName']
  switch = env.get_switch(message['switchName'])
  rpcReply(switch.get_state(), args)


def list_switches(message, args):
  env.discover(seconds=5)
  print "discovery finished.... dumping"
  switches = []
  for switch in env.list_switches():
    switches.append({
      "name": switch,
      "status": env.get_switch(switch).get_state()
      })
  print "listing finished dumping to json"
  print json.dumps(switches)
  rpcReply(switches, args)

def rpcReply(message, args):
  args['ch'].basic_publish(exchange='',
                   routing_key=args['props'].reply_to,
                   properties=pika.BasicProperties(correlation_id = \
                               args['props'].correlation_id),
                   body=json.dumps(message))

operations = {
  "list_switches" : list_switches,
  "toggle_on" : toggle_on,
  "toggle_off" : toggle_off,
  "status" : toggle_on
}
def on_request(ch, method, props, body):
  args = {
    "ch": ch,
    "method": method,
    "props": props,
    "body": body
  }
  message = json.loads(body)
  print "Received message ",message
  operations[message['operation']](message, args)
  ch.basic_ack(delivery_tag = method.delivery_tag)

channel.basic_qos(prefetch_count=1)
channel.basic_consume(on_request, queue='wemo.lights')

print "server now listening..."
channel.start_consuming()

