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

with Connection('amqp://backendclient:passowrd@galactica:5672//') as conn:

    tn = telnetlib.Telnet("192.168.1.10", "4025")
    tn.set_debuglevel(10)
    tn.read_until("Login:")
    tn.write("password" + "\r\n")
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

    output = ""

    while True:
        # time.sleep(1)

        newOutput = tn.read_some().strip()
        if len(newOutput) > 1:
	    output = newOutput

        producer.publish(exchange = 'eyezon.alarm', routing_key = "", body = output)

        try:
            conn.drain_events(timeout=1)
        except socket.timeout:
            print "no new messages"

