#!/usr/bin/env bash

basedir=$(dirname $0)
echo "base dir ${basedir}"

currentVersion=$(${basedir}/getVersion.sh)

echo "current version ${currentVersion}"

if [[ "${currentVersion}" == *-SNAPSHOT ]]
then
    newVersion=$(echo ${currentVersion} | cut -d\- -f1)
    echo "new Version is ${newVersion}"
    
    ${basedir}/setVersion.sh ${newVersion}
else
    echo "Current version is not a snapshot, can't be closed"
    exit 1
fi


