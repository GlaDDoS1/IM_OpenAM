#!/bin/bash

################################################################################
#  Educational Online Test Delivery System
#  Copyright (c) 2013 American Institutes for Research
#
#  Distributed under the AIR Open Source License, Version 1.0
#  See accompanying file AIR-License-1_0.txt or at
#  https://bitbucket.org/sbacoss/eotds/wiki/AIR_Open_Source_License
################################################################################

MAINDIR="/opt"                           # all files will be installed in this folder
SCRIPTDIR="$MAINDIR/scripts"             # location of the script directory
LOGSDIR="$MAINDIR/scripts/logs"          # location of the script directory
TOMCATDIR="$MAINDIR/tomcat"              # location of the open installation directory
INSTALLUSER="root"                       # user who is performing the installation
OPENAMUSER="openam"                      # user that tomcat/OpenAM will run as
OPENAMTOOLSDIR="$MAINDIR/openamtools"    # location of openamtools
JAVAVERSION="1.7.0_76"                   # java version this server has been tested with
SSOADM="$OPENAMTOOLSDIR/auth/bin/ssoadm" # location of ssoadm
PWDFILE="$OPENAMTOOLSDIR/pwd.txt"        # password file used by ssoadm

su - openam -c $TOMCATDIR/bin/shutdown.sh
NETSTAT=`netstat -lnt |awk '$6 == "LISTEN" && $4 ~ ":8080"'`
count=1
while [[ "$NETSTAT" != "" ]]; do
    ((count++))
    if [ $count -gt 120 ]; then
        echo "ERROR: Tomcat is not shutting down in a timely fashion.  Please check $TOMCATDIR/logs/catalina.out for errors."
        echo
        exit
    fi
    sleep 1
    NETSTAT=`netstat -lnt |awk '$6 == "LISTEN" && $4 ~ ":8080"'`
done
cd /opt
CWD=`pwd`
if [[ "$CWD" != "$MAINDIR" ]]; then
    echo "ERROR: Not in the $MAINDIR folder!"
    echo
    exit
else
    rm -rf artifacts/ installOpenAM.sh openamtools/ tomcat/
    cd openam
    CWD=`pwd`
    if [[ "$CWD" != "$MAINDIR/openam" ]]; then
        echo "ERROR: Not in the $MAINDIR/openam folder!"
        echo
        exit
    else
        rm -rf *
        rm -rf .openamcfg
        rm -rf .version
    fi
fi
