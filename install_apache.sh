#!/bin/bash
apt -y update
apt-get -y install tomcat9
apt-get -y install iptables
iptables --insert INPUT --protocol tcp --dport 80 --jump ACCEPT
iptables --insert INPUT --protocol tcp --dport 8080 --jump ACCEPT
iptables --table nat --append PREROUTING --in-interface eth0 --protocol tcp --dport 80 --jump REDIRECT --to-port 8080
service iptables save
service tomcat9 start
