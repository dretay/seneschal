Seneschal
=====
Seneschal(n): An official in a medieval noble household in charge of domestic arrangements and the administration of servants; a steward

#Overview
Seneschal is a home automation server built entirely on IP-based technologies. Currently it integrates with:
- Belkin WEMO Switches
- EnvisaLink 3 IP Security Interface Module
- Foscam Cameras
- Nest Thermostat

#Screenshots
Here are some screenshots:
- [Alarm panel]
- [Cameras]
- [Lights]
- [Menu system]
- [Thermostat]

#Architecture
When building my home automation server I encountered some major deficiencies with the products I was buying:

1. Nothing supports SSL out of the box. That means that any time you access a resource over the internet you are sending your credentials unencrypted for anyone to see. Even if they did support SSL, buying and renewing a new cert for every device would be prohibitivly expensive. 
2. There is no capability to perform a single sign on. You must create and maintain an account for every device you install in your network. 
3. There is no common wire format all the technologies use to communicate. Some use TCP sockets, some present a REST interface, and others use SOAP. 

To solve the above problems I decided on the architecture below:
![architecture diagram](https://raw.github.com/dretay/seneschal/master/imgs/seneschal_architecture.png)
At a high level what is happening is that a client will connect to the NGINX proxy and then be routed to the appropriate back-end service. In the case of streaming resources like cameras they will be routed directly to the requested resource. All other requests are funneled through a local RabbitMQ broker. This allows me to customize how clients interract with resources (since I can choose the appropriate topology for the use case). 

When a user connects to a resource one of the things that it presents is a "token" for authentication. This token is an AES256 encrypted JSON string representing resource, username, password tuples. Using its LUA runtime NGINX is able to decrypt the token and dynamically rewrite the URL so that it contains the appropriate credentials. Since only the server is ever aware of the passphrase for the token, it is cryptographically secure. If the token is ever compromised all you need to do is revoke the token by changing the passhprase NGINX uses to decrypt the token. An attacker would not be able to decrypt the token, so it become effectively useless.  


 
[Alarm panel]:https://github.com/dretay/seneschal/master/imgs/alarm.png
[cameras]:https://raw.github.com/dretay/seneschal/master/imgs/cameras.png
[lights]:https://raw.github.com/dretay/seneschal/master/imgs/lights.png
[menu system]:https://raw.github.com/dretay/seneschal/master/imgs/menu.png
[thermostat]:https://raw.github.com/dretay/seneschal/master/imgs/thermostat.png
