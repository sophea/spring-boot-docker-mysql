#!/usr/bin/env bash

basedir=$(dirname $0)
instance_name=$(cat ${basedir}/instance_name)
version=$(${basedir}/version/getVersion.sh)
nexusData=`cat ${basedir}/nexus.data`

~/.docker_login.sh $nexusData

echo Pushing version ${version} of ${instance_name}
docker push ${nexusData}/${instance_name}:${version}
