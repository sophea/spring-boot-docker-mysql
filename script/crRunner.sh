#!/usr/bin/env bash
### BEGIN INIT INFO
# Provides:          bombardier backend
# Required-Start:    $syslog
# Required-Stop:     $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Provides continuous release for bombardier project
# Description:       Provides continuous release for bombardier project
#
### END INIT INFO
#
# There should be a cron task running this script with the "upgrade" option periodically to keep the server alive and updated.
#
#  */10 * * * * /opt/repository/bombardier-backend/scripts/crRunner.sh upgrade >> /var/log/bombardier/cron-task-backend.log 2>&1
#

define_variables () {
    runtimeFolder=/opt/bombardier/backend
    nexusBasePath="https://nexus.dminc-gtc.com/nexus/content/repositories/releases/com/dminc/bombardier/bombardier-app/"
    metadataUrl="${nexusBasePath}maven-metadata.xml"
    currentVersionFile=$runtimeFolder/current.version
    gitFolder=/opt/repository/bombardier-backend
    pidFile=${runtimeFolder}/server.pid
    logFile=/var/log/bombardier/backend-server.log
    gcLogFile=/var/log/bombardier/backend-server-gc.log
    java_executable=java
    jar_file="$runtimeFolder/app.jar"
    java_options="-server"
    java_options="$java_options -Xms256m -Xmx512m"
    java_options="$java_options -XX:MaxMetaspaceSize=256m"
    java_options="$java_options -XX:SurvivorRatio=8"
    java_options="$java_options -XX:+UseConcMarkSweepGC -XX:+CMSParallelRemarkEnabled"
    java_options="$java_options -XX:+UseCMSInitiatingOccupancyOnly -XX:CMSInitiatingOccupancyFraction=70"
    java_options="$java_options -XX:+ScavengeBeforeFullGC -XX:+CMSScavengeBeforeRemark"
    java_options="$java_options -XX:+PrintGCDateStamps -verbose:gc -XX:+PrintGCDetails -Xloggc:$gcLogFile"
    java_options="$java_options -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=10 -XX:GCLogFileSize=100M"
    java_options="$java_options -Dsun.net.inetaddr.ttl=180"
    java_options="$java_options -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=$runtimeFolder/`date +"%F\ %T"`.hprof"
    java_options="$java_options -jar $jar_file"
    app_process_token=bombardierBackendAppRunning
    activeProfileFile=`dirname ~/.`
    activeProfileFile="$activeProfileFile/.bombardier-backend/profile"
    if [ -f $activeProfileFile ]; then
        activeProfile=`cat $activeProfileFile`
        echo "This environment specifies active profile is $activeProfile"
    else
        echo "This environment does not specify an active profile in $activeProfileFile. Assuming TEST."
        activeProfile=TEST
    fi

    crModeFile=`dirname ~/.`
    crModeFile="$crModeFile/.bombardier-backend/crMode"
    if [ -f $crModeFile ]; then
        crMode=`cat $crModeFile`
        echo "This environment specifies Continuous Release mode is $crMode"
    else
        echo "This environment does not specify Continuous Release mode in $crModeFile. Assuming git."
        crMode="git"
    fi

    runModeFile=`dirname ~/.`
    runModeFile="$runModeFile/.bombardier-backend/runMode"
    if [ -f $runModeFile ]; then
        runMode=`cat $runModeFile`
        echo "This environment specifies run mode is $runMode"
    else
        echo "This environment does not specify run mode in $runModeFile. Assuming JDK."
        runMode="JDK"
    fi

    app_options="--spring.profiles.active=$activeProfile -D${app_process_token}=true"

    export TERM=xterm
}

rootcheck () {
    user=`ls -l $0 | awk '{ print $3 }'`

    if [ $(id -u) == "0" ]
    then
        echo This command must not be executed as root. It may create files with wrong permissions which later the ${user} user will not be able to modify.
        exit 1
    fi

    myself=`whoami`
    if [ "$myself" != "$user" ]; then
        echo This command must be executed with user ${user}, which is the owner of the file.
        exit 1
    fi
}

start() {
    if [ ! -f ${jar_file} ]; then
        echo "Executable jar file $jar_file does not exist. Generating..."
        if [ "$crMode" == "nexus" ]; then
            download;
        else
            compile;
        fi;
    fi

    if [ "$runMode" == "JDK" ]; then
        command=" $java_executable $java_options $app_options "
        echo "Starting daemon using command: "$command
        /sbin/start-stop-daemon --start --quiet --background --make-pidfile --pidfile ${pidFile} --chuid $user:$user --startas /bin/bash -- -c "exec $command >> ${logFile} 2>&1";
    elif [ "$runMode" == "docker" ]; then
        if [ "$crMode" == "nexus" ]; then
            echo "Run mode $runMode with crMode=$crMode still not implemented."
        else
           $gitFolder/scripts/docker-build-image.sh
           $gitFolder/scripts/docker-start-image.sh $activeProfile
        fi;
    else
        echo "Unknown run mode $runMode"
    fi
}

stop() {
    if [ "$runMode" == "JDK" ]; then
        echo "Stopping daemon..."
        /sbin/start-stop-daemon -K --pidfile ${pidFile};
        sleep 5;
        echo "Deleting ${pidFile}"
        rm -rf ${pidFile}
        stillRunnningPid=`ps aux | grep "${app_process_token}" | grep -v grep | awk '{print $2;}'`
        if [ -n "$stillRunnningPid" ]
        then
            echo "Process still running under PID $stillRunnningPid. Killing it."
            kill ${stillRunnningPid}
        fi
    elif [ "$runMode" == "docker" ]; then
        if [ "$crMode" == "nexus" ]; then
            echo "Run mode $runMode with crMode=$crMode still not implemented."
        else
           $gitFolder/scripts/docker-stop-image.sh
        fi;
    else
        echo "Unknown run mode $runMode"
    fi
}

pull() {
    echo "Pulling git repo in $gitFolder"
    (cd ${gitFolder} && exec git pull);
}

download() {
    version=$1
    url=${nexusBasePath}${version}/bombardier-app-${version}.jar
    echo Downloading from nexus, version $version, url=$url
    echo Stopping first
    stop
    curl -o $jar_file $url;
    echo Starting with new version
    start
}

compile() {
    echo "Compiling new version of the project"
    (cd ${gitFolder} && exec ${gitFolder}/gradlew clean check build);
    version=`cat $gitFolder/gradle.properties | grep version | cut -d\=  -f2`
    artifactName=`cat $gitFolder/layer-app/build.gradle | grep archivesBaseName | cut -d\=  -f2 | cut -d\" -f2`
    filename=$artifactName-$version.jar

    if [ -e $gitFolder/layer-app/build/libs/$filename ]; then
        stop;
        cp $gitFolder/layer-app/build/libs/$filename $jar_file
        start;
    fi
}


upgradeViaNexus() {
    currentNexusVersion=`curl -X GET $metadataUrl | grep "<release>" | cut -d \>  -f2 | cut -d\< -f1`
    currentVersion=
    if [ -e $currentVersionFile ]; then
        currentVersion=`cat $currentVersionFile`
    else
        currentVersion="0.0.0.0"
    fi

    echo "Version currently deployed is $currentVersion, last version in nexus is $currentNexusVersion"

    if [ "$currentVersion" != "$currentNexusVersion" ];
    then
        download $currentNexusVersion;
        echo "$currentNexusVersion" > $currentVersionFile;
    fi

    verifyItIsRunning;
}

verifyItIsRunning() {
    if [ "$runMode" == "JDK" ]; then
        if [ -f  ${pidFile} ] && [ -e /proc/`cat ${pidFile}` ]
        then
            echo "Bombardier train backend is running with pid=`cat ${pidFile}`"
        else
            echo "Bombardier train backend is not running. Starting it up."
            start;
        fi
    elif [ "$runMode" == "docker" ]; then
        echo "Runmode is docker. Delegating instance lifecycle to docker daemon..."
    else
        echo "Unknown run mode $runMode"
    fi
}

upgradeViaGit() {
    myBranch=`(cd ${gitFolder} && exec git rev-parse --abbrev-ref HEAD)`;
    (cd ${gitFolder} && exec git fetch);
    offsets=`(cd ${gitFolder} && exec git rev-list --left-right --count origin/$myBranch...$myBranch)`;
    commitsBehindParent=`echo $offsets | cut -d\  -f1`;
    echo $commitsBehindParent commits behind parent branch \(origin/$myBranch\)
    if [ $commitsBehindParent -ne "0" ]
    then
        pull && compile;
    fi
    verifyItIsRunning;
}

upgrade() {
    if [ "$crMode" == "nexus" ]; then
        upgradeViaNexus;
    else
        upgradeViaGit;
    fi;
}

rootcheck;

case "$1" in
  start)
    define_variables;
    start;
    ;;
  stop)
    define_variables;
    stop;
    ;;
  upgrade)
    define_variables;
    upgrade;
    ;;
  *)
    echo "Usage: $0 {start|stop|upgrade}"
    exit 1
    ;;
esac

exit 0
