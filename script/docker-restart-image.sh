#!/usr/bin/env bash

basedir=$(dirname $0)
${basedir}/docker-stop-image.sh
${basedir}/docker-start-image.sh $1 $2

