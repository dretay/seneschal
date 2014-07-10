var MjpegProxy = require('mjpeg-proxy').MjpegProxy;
var auth = require('http-auth');
var express = require('express');
var IniReader = require('inireader');
var parser = new IniReader.IniReader();
parser.load('../config/site.ini');
var foscamUsername = parser.param('foscam.username');
var foscamPassword = parser.param('foscam.password');
var basic = auth.basic({
    realm: "Simon Area.",
    file: __dirname + "/users.htpasswd" // gevorg:gpass, Sarah:testpass ...
});

var app = express();
app.use(auth.connect(basic));
app.get('/livingroom', new MjpegProxy('http://192.168.1.16:8082/videostream.cgi?user='+foscamUsername+'&pwd='+foscamPassword+'&rate=3&time=1404954169540').proxyRequest);

app.get('/porch', new MjpegProxy('http://192.168.1.18:8083/videostream.cgi?user='+foscamUsername+'&pwd='+foscamPassword+'&rate=3&time=1404954169540').proxyRequest);

app.get('/basement', new MjpegProxy('http://192.168.1.15:8081/videostream.cgi?user='+foscamUsername+'&pwd='+foscamPassword+'&rate=3&time=1404954169540').proxyRequest);

app.get('/frontdoor', new MjpegProxy('http://192.168.1.17:8080/videostream.cgi?user='+foscamUsername+'&pwd='+foscamPassword+'&rate=3&time=1404954169540').proxyRequest);

console.log("Camera proxies started successfully!");
app.listen(8080, "0.0.0.0");

