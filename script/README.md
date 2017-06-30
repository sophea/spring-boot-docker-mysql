The crRunner.sh script in this folder help continuous releasing (CR) in GCE servers. It reads from file  ~/.test-backend-backend/crMode the
mode it should operate, it must be either "git" or "nexus". This script should be run by a user created specifically for running the
test-backend backend server, for example, "test-backend".

The idea is to have a crontab task in this user executing ```crRunner.sh upgrade``` periodically, for example, every 10 minutes:
```
 #  */10 * * * * /opt/repository/test-backend-backend/scripts/crRunner.sh upgrade >> /var/log/test-backend/cron-task.log 2>&1
```

The script reads from the crMode file the value either "git" or "nexus" and operates accordingly.

git Mode
------------
CR based on git repo. The server must have a copy of the git repo in /opt/repository/test-backend-backend/ which is kept up to date by executing
```gitRunner.sh upgrade```. There must exist a test-backend user which has to be the owner of this repository, the same that runs the backend server.
With this mode, every commit made to the branch the server has checked out will make the server re-compile and re-run it, whenever the cron
task runs (if there is anything new since last execution).

nexus mode
--------------
CR based on nexus releases. The server does not need to have a copy of the git repo, only this script. With this mode, every release made from jenkins
to nexus will be downloaded and run in this server whenever the cron task runs (if there is anything new since last execution). In order to do that,
the script reads and interprets the maven-metadata.xml file in nexus. The last release specified there is compared with the release currently running,
and if they differ, the nexus release is downloaded and started.

docker login username pasword hostname

create new file ~/.docker_login.sh as content below

#!/usr/bin/env bash

docker login -u jbackend -p ZxxxxQ $1


See docker-push-image.sh

Configuration
--------------
The script uses /opt/test-backend folder as auxiliary storage for the jar file that is run and starts the test-backend Backend, whether it was by compiling it
(git mode) or downloading it from nexus (nexus mode).

 * It reads from ```~/.test-backend/profile``` file the environment name (TEST, DEV, PROD, etc.) If it doesn't exist, TEST is assumed.
 * It uses some generic server options (memory size, etc.) which can be seen in the script.
 * It redirects the server output to /var/log/test-backend/backend-server.log and GC log to /var/log/test-backend/backend-server-gc.log


