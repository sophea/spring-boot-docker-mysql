#!/usr/bin/env bash

basedir=$(dirname $0)

VERSION=$(grep --max-count=1 '<version>' $basedir/../../pom.xml | awk -F '>' '{ print $2 }' | awk -F '<' '{ print $1 }')
echo $VERSION
