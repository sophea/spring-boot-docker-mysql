#!/usr/bin/env bash

if [ "$1" = "" ]; then
    echo "ERROR. Must pass the version to set, for example: $0 1.0.0-SNAPSHOT"
    exit 1;
fi

basedir=$(dirname $0)
currentVersion=$(${basedir}/getVersion.sh)

#replace all lines /g
#sed -i -- 's/'${currentVersion}'/'${1}'/g' ${basedir}/../../pom.xml

#replace for line only
sed -i -- '0,/'${currentVersion}/' s/'/${1}/'' ${basedir}/../../pom.xml

