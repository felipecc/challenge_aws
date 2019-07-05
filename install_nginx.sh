#!/bin/bash
apt -y update
apt-get -y install nginx
ufw allow 'Nginx HTTP'