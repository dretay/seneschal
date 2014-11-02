Seneschal(n):
=====
1. An official in a medieval noble household in charge of domestic arrangements and the administration of servants; a steward
2. Yet another home automation server running on a Raspberry PI.

#Overview
Seneschal is a polyglot collection of Python and NodeJS daemons that communicate with each other over RabbitMQ. The front end is an AngularJS-based web page hosted on an OpenResty server that interacts with the back-end daemons over Web STOMP.

##Screenshots
In case you are curious what this all looks like, I'll try to keep these screens as up-to-date as possible.
The basic idea is that you can access all the devices on in your home through a bird's eye [floorplan] of your house.
You can click on things like [cameras] or [thermostats] to bring up a control dialog.
You can also ask interesting questions by querying [historical data] that is stored and indexed by the server.
You can even check on the server itself through real time [system stats] and a page that allows you to [toggle daemons].
Finally because everything is driven over RabbitMQ you can write your own [rules] in Coffeescript to react to events occuring in the house.

##Supported Devices
- [Belkin WEMO Switches]
- [EnvisaLink 3 IP Security Interface Module]
- [Foscam Cameras]
- [Nest Thermostat]
- [MySensors-based Devices]

#Architecture
I decided to build my own home automation server because I encountered some major deficiencies with the products I was buying:

1. Nothing supported self-hosted SSL. That meant that I had to choose between sending my credentials unencrypted for anyone to see or allowing the manufacturer to store all of my data.
2. There was no capability to perform a single sign on; I had to create and maintain an account for every device I installed in my network.
3. There was no common wire format all the technologies use to communicate. Some use TCP sockets, some present a REST interface, and others use SOAP.


To solve these above problems I decided to build a system that is structured like this:
![architecture ](https://raw.github.com/dretay/seneschal/master/imgs/architecture.png)

The basic idea is that when a user logs into the webpage they are authenticated through a LUA-based authentication module in OpenResty and then connected directly to the RabbitMQ broker over Web Stomp. The browser will then subscribe to the appropriate queues and exchanges to query the daemons and issue commands.

Notably there is no real application server in this diagram. Static web resources are served up through Nginx / Openresty and everything else is handled within AngularJS itself. I did this intentionally because this runs on a Raspberry PI, which does not have the resources to run a responsive application server along with all the back-end daemons.

#Todo
There are several projects currently conflated into this repository. Major pieces of functionality should probably be broken out into separate projects, resulting in this repository serving more as an umbrella that integrates plugins. Major pieces of functionality to export include:

- The adapter for doing CRUD in AngularJS over WebStomp
- The LUA module for authentication management
- The daemons themselves that abstract interacting with the raw devices (specifically the Envisalink stuff)


[floorplan]:https://raw.github.com/dretay/seneschal/master/imgs/main_floor_controls.png
[historical data]:https://raw.github.com/dretay/seneschal/master/imgs/sensor_history.png
[thermostats]:https://raw.github.com/dretay/seneschal/master/imgs/thermostat.png
[cameras]:https://raw.github.com/dretay/seneschal/master/imgs/camera.png
[rules]:https://raw.github.com/dretay/seneschal/master/imgs/rules_example.png
[system stats]:https://raw.github.com/dretay/seneschal/master/imgs/system_stats.png
[toggle daemons]:https://raw.github.com/dretay/seneschal/master/imgs/supervisord_control.png
[Belkin WEMO Switches]:http://www.belkin.com/us/Products/home-automation/c/wemo-home-automation/
[EnvisaLink 3 IP Security Interface Module]:http://www.eyezon.com/
[Foscam Cameras]:http://foscam.us/
[Nest Thermostat]:https://nest.com/
[MySensors-based Devices]:http://mysensors.org
[Responsive UI]:http://en.wikipedia.org/wiki/Responsive_web_design
[LUA runtime]:https://github.com/chaoslawful/lua-nginx-module
[horizontally scalable]:http://en.wikipedia.org/wiki/Scalability
