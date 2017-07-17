#!/bin/bash

HOSTIP=`ip -4 addr show scope global dev eth0 | grep inet | awk '{print \$2}' | cut -d / -f 1`

docker run -it -d --name web-app \
              --add-host=local:${HOSTIP} \
              -p 8080:8080 \
              -e DATABASE_HOST=${HOSTIP} \
              -e DATABASE_PORT=3306 \
              -e DATABASE_NAME=demo \
              -e DATABASE_USER=root \
              -e DATABASE_PASSWORD=root \
              sopheamak/springboot_docker_mysql