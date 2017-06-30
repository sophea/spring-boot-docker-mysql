#!/usr/bin/env bash

if [ "${activeProfile}" = "" ]; then
    echo "ERROR: An environment variable named activeProfile must be set with value DEV, PROD, TEST or STAGE so that spring-boot will choose the right configuration."
    exit 1
fi

if [ "${serverPort}" = "" ]; then
    serverPort=8080
    echo "WARNING: An environment variable named serverPort should be set. Assuming port ${serverPort} by default."
fi

java -server\
 -Xms256m\
 -Xmx512m\
 -XX:MaxMetaspaceSize=256m\
 -XX:SurvivorRatio=8\
 -XX:+UseConcMarkSweepGC\
 -XX:+CMSParallelRemarkEnabled\
 -XX:+UseCMSInitiatingOccupancyOnly\
 -XX:CMSInitiatingOccupancyFraction=70\
 -XX:+ScavengeBeforeFullGC\
 -XX:+CMSScavengeBeforeRemark\
 -XX:+PrintGCDateStamps\
 -Dsun.net.inetaddr.ttl=180\
 -XX:+HeapDumpOnOutOfMemoryError\
 -jar\
 /app/app.jar\
 --spring.profiles.active=${activeProfile}\
 --server.port=${serverPort}\

