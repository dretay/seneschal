import socket
import datetime
import time
from kombu import Connection, Producer, Exchange, Queue, Consumer
from contextlib import closing
import telnetlib
from inspect import getmembers
from pprint import pprint

def send_cmd(body,message):
    tn.write(body.encode('utf-8')+"\r\n")

with Connection('amqp://backendclient:WwTMfbtzxGNGhte0kxao@galactica:5672//') as conn:

    tn = telnetlib.Telnet("192.168.1.10", "4025")
    tn.set_debuglevel(10)
    tn.read_until("Login:")
    tn.write("peanut" + "\r\n")
    tn.read_until("OK")

    queue = Queue(
        name="eyezon.alarm",
        exchange=Exchange(''),
        channel=conn.channel(),
        durable=False,
        exclusive=False,
        auto_delete=True)


    producer = Producer(conn.channel(), exchange = Exchange('eyezon.alarm', type='fanout'), serializer="json")
    consumer = Consumer(conn.channel(), queues = queue, auto_declare=True, callbacks=[send_cmd])
    consumer.consume(no_ack=False)

    while True:
        # time.sleep(1)

        output = tn.read_some().strip()
        if len(output) > 1:
            producer.publish(exchange = 'eyezon.alarm', routing_key = "", body = output)

        try:
            conn.drain_events(timeout=1)
        except socket.timeout:
            print "no new messages"



        # message = queue.get(block=True, timeout=1)
        # entry = message.payload
        # tn.write(entry + "\r\n")
        # message.ack()





# class Logger(object):

#     def __init__(self, connection, queue_name='log_queue',
#             serializer='json', compression=None):
#         self.queue = connection.SimpleQueue(queue_name)
#         self.serializer = serializer
#         self.compression = compression

#     def log(self, message, level='INFO', context={}):
#         self.queue.put({'message': message,
#                         'level': level,
#                         'context': context,
#                         'hostname': socket.gethostname(),
#                         'timestamp': time.time()},
#                         serializer=self.serializer,
#                         compression=self.compression)

#     def process(self, callback, n=1, timeout=1):
#         for i in xrange(n):
#             log_message = self.queue.get(block=True, timeout=1)
#             entry = log_message.payload # deserialized data.
#             callback(entry)
#             log_message.ack() # remove message from queue

#     def close(self):
#         self.queue.close()


# if __name__ == '__main__':
#     from contextlib import closing

#     with Connection('amqp://guest:guest@galactica:5672//') as conn:
#         with closing(Logger(conn)) as logger:
#             mins = 0
#             while mins != 20:
#                 time.sleep(1)
#                 # Increment the minute total
#                 mins += 1
#                 # Send message
#                 logger.log('Error happened while encoding video',
#                             level='ERROR',
#                             context={'filename': 'cutekitten.mpg'})

#                 # Consume and process message

#                 # This is the callback called when a log message is
#                 # received.
#                 def dump_entry(entry):
#                     date = datetime.datetime.fromtimestamp(entry['timestamp'])
#                     print('[%s %s %s] %s %r' % (date,
#                                                 entry['hostname'],
#                                                 entry['level'],
#                                                 entry['message'],
#                                                 entry['context']))

#                 # Process a single message using the callback above.
#                 logger.process(dump_entry, n=1)
