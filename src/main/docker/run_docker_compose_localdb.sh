#!/bin/bash

##HOSTIP=`ip -4 addr show scope global dev eth0 | grep inet | awk '{print \$2}' | cut -d / -f 1`
export HOSTIP=$(ifconfig | grep -E "([0-9]{1,3}\.){3}[0-9]{1,3}" | grep -v 127.0.0.1 | awk '{ print $2 }' | cut -f2 -d: | head -n1
echo "IP address from docker ${HOSTIP}"
docker-compose -f docker-compose-localdb.yml up