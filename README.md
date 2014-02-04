Seneschal(n):
=====
1. An official in a medieval noble household in charge of domestic arrangements and the administration of servants; a steward
2. A home automation server built entirely on IP-based technologies. 

#Overview
Seneschal is a polyglot colletion of python daemons, lua scripts, and javascript that  presents a unified way of interracting with different IP-based home automation technologies. The aim is build a [Responsive UI] that can be used across many devices (mobile, desktop, tablet...). 

One interesting design feature of Seneschal is that you do not need to log into the system per se. When you visit the front end you do so with a URL that looks something like this https://www.myhomeautomationserver.com/html/index-optimize.html#/home/Z2%252Fih%252Fsqp1eQeV6CpF%252Z2%252B/lights. That crazy looking string of characters in the middle of the URL is actually an AES256 encrypted list of all the usernames and passwords for the devices on your network. Seneschal will transparently decrypt that url when you access a resoruce (such as a web cam), extract the appropriate credentials, and apply them to the connection. That means that you can have "persistent" bookmarks to pages without worrying about remembering all your usernames and passwords. 

##Screenshots
I case you are curious what this all looks like, I'll try to keep these screens as up-to-date as possible. The basic idea is that you can access all the devices in your home such as your [Alarm panel], [Cameras], [Lights], and [Thermostat] and switch between them with this [Menu system].

##Compatibility
- [Belkin WEMO Switches]
- [EnvisaLink 3 IP Security Interface Module]
- [Foscam Cameras]
- [Nest Thermostat]

#Architecture
When building my home automation server I encountered some major deficiencies with the products I was buying:

1. Nothing supports SSL out of the box. That means that any time you access a resource over the internet you are sending your credentials unencrypted for anyone to see. Even if they did support SSL, buying and renewing a new cert for every device would be prohibitively expensive. 
2. There is no capability to perform a single sign on. You must create and maintain an account for every device you install in your network. 
3. There is no common wire format all the technologies use to communicate. Some use TCP sockets, some present a REST interface, and others use SOAP. 

To solve the above problems I decided on the architecture below:
![architecture diagram](https://raw.github.com/dretay/seneschal/master/imgs/seneschal_architecture.png)
At a high level what is happening is that a client will connect to the NGINX proxy and then be routed to the appropriate back-end service. In the case of streaming resources like cameras they will be routed directly to the requested resource. All other requests are funneled through a local RabbitMQ broker. This allows me to customize how clients interact with resources (since I can choose the appropriate topology for the use case). 

When a user connects to a resource one of the things that it presents is a "token" for authentication. This token is a URL-encoded, AES256 encrypted, JSON string representing resource, username, password tuples. Using this awesome [LUA runtime] plugin NGINX has been extended to decrypt the token and dynamically rewrite the URL so that it contains the appropriate credentials. Since only the server is ever aware of the passphrase for the token, it is cryptographically secure. If the token is ever compromised all you need to do is revoke the token by changing the passhprase NGINX uses to decrypt the token. An attacker would not be able to decrypt the token, so it become effectively useless.  

#Scalability
I think this solution should be [horizontally scalable] to accomidate high ammounts of load. You can easily add additinal NGINX proxies or RabbitMQ brokers as necessary. You should also be able to implement policies within RabbitMQ as necessary to funnel traffic. Since everything is stateless and messaging based there is no single point of failure within the architecture, which should allow for several 9's of uptime. 
 
[Alarm panel]:https://github.com/dretay/seneschal/master/imgs/alarm.png
[cameras]:https://raw.github.com/dretay/seneschal/master/imgs/cameras.png
[lights]:https://raw.github.com/dretay/seneschal/master/imgs/lights.png
[menu system]:https://raw.github.com/dretay/seneschal/master/imgs/menu.png
[thermostat]:https://raw.github.com/dretay/seneschal/master/imgs/thermostat.png
[Belkin WEMO Switches]:http://www.belkin.com/us/Products/home-automation/c/wemo-home-automation/
[EnvisaLink 3 IP Security Interface Module]:http://www.eyezon.com/
[Foscam Cameras]:http://foscam.us/
[Nest Thermostat]:https://nest.com/
[Responsive UI]:http://en.wikipedia.org/wiki/Responsive_web_design
[LUA runtime]:https://github.com/chaoslawful/lua-nginx-module
[horizontally scalable]:http://en.wikipedia.org/wiki/Scalability
