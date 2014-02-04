import socket
import datetime
import time
from kombu import Connection, Producer, Exchange, Queue, Consumer
from nest import Nest

#nest.status['shared'][nest.serial]

def send_cmd(body,message):
    newTemp = int(body.encode('utf-8'))
    print "setting temperature to ", newTemp
    nest.set_temperature(newTemp)

with Connection('amqp://rabbitUsername:rabbitPassword@galactica:5672//') as conn:
    nest = Nest('nestAccount', 'nestPassword', units="F")
    nest.login()

    nest.get_status()

    queue = Queue(
        name="nest.thermostat",
        exchange=Exchange(''),
        channel=conn.channel(),
        durable=False,
        exclusive=False,
        auto_delete=True)


    producer = Producer(conn.channel(), exchange = Exchange('nest.thermostat', type='fanout'), serializer="json")
    consumer = Consumer(conn.channel(), queues = queue, auto_declare=True, callbacks=[send_cmd])
    consumer.consume(no_ack=False)
 
    cnt = 0
    while True:
        if cnt % 5 == 0:
            print "querying for status"
            nest.get_status()

        output = nest.status['shared'][nest.serial]
        if len(output) > 1:
            producer.publish(body = output)

        try:
            conn.drain_events(timeout=5)
        except socket.timeout:
            print "no new messages"

	cnt +=1
