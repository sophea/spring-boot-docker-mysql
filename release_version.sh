#!/usr/bin/env bash

basedir=$(dirname $0)

${basedir}/script/version/closeVersion.sh


git add .
git commit -m "AUTOMATIC: Closed release `./script/version/getVersion.sh`"
git tag -a `./script/version/getVersion.sh` "relese version `./script/version/getVersion.sh`"
git push --set-upstream --tags

${basedir}/script/version/increaseVersion.sh
git add version
git commit -m "AUTOMATIC: Created new snapshot version `./script/version/getVersion.sh`"
git push --set-upstream origin master
