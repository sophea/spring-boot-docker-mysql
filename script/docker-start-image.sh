#!/usr/bin/env bash

if [ "$1" = "" ]; then
    echo "WARNING. No parameters passed to $0. Pass environment name (such as TEST, STAGE, etc.) to force specific spring-boot settings. Assuming DEV."
    export activeProfile="DEV"
else
    export activeProfile=$1
fi

basedir=$(dirname $0)
instance_name=$(cat ${basedir}/instance_name)
export version=$(${basedir}/version/getVersion.sh)
echo  version=${version} > .env

docker-compose --version

docker-compose -f ${basedir}/docker-compose.yml run -d --service-ports --name ${instance_name} ${instance_name}

