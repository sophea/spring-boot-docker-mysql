#!/bin/bash

mysql_host=${DATABASE_HOST}
mysql_port=${DATABASE_PORT}

echo " $mysql_host $mysql_port"

shift 2
cmd="$@"
# wait for the mysql docker to be running
while ! nc $mysql_host $mysql_port; do
  echo "mysql is unavailable - sleeping 1"
  sleep 10
done

>&2 echo "mysql is up executing command"
# run the command
exec $cmd

java -Djava.security.egd=file:/dev/./urandom -jar /demo.jar