#!/usr/bin/env bash

basedir=$(dirname $0)
instance_name=$(cat ${basedir}/instance_name)

existingId=$(docker ps -a -f name=${instance_name} -q)

if [ "$existingId" = "" ]; then
    echo The ${instance_name} docker container is not running.
else
    docker rm -f ${existingId}
fi

