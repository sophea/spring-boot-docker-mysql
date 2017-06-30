#!/usr/bin/env bash

basedir=$(dirname $0)
instance_name=$(cat ${basedir}/instance_name)
version=$(${basedir}/version/getVersion.sh)
nexusData=`cat ${basedir}/nexus.data`

docker build -t ${instance_name}:${version} ${basedir}
docker tag ${instance_name}:${version} ${nexusData}/${instance_name}:${version}
