#!/bin/bash
apt -y update
apt-get -y install tomcat9
service tomcat9 start
iptables -t nat -A OUTPUT -o lo -p tcp --dport 80 -j REDIRECT --to-port 8080