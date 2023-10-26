#!/bin/ksh
##################################################################################
# 
# Desc: This script is a complete rewrite of the original script that pulled
#       the messages from the referenced Sybase Replication Error Log on
#       a continous basis from the referenced Linux host to a centralized Linux 
#       Server for monitoring by the Logic Monitor collector. 
#
#       This script CALLS the script LMSybLogRefresh.sh, which performs the actual
#       log "pull" action 
# Author: Will Landstrom-Spinnaker Support
# Date: 7-9-2023
# Version: 1.01
set -xv
## 
##################################################################################
echo "===========Welcome to PullRepServerLog.sh======================================"
#Step01 - source in the environment file
display_usage()
{
        echo "This script requires 1 parameter, the name of the associated env file"
        echo -e "\nUsage : $0 [arguments] \n"
}
if [ $# -lt 1 ]
then
        display_usage
        exit 1
fi
ThisScriptName=$0
EnvFileToUse=$1
ThisScriptDir=$(readlink -f "$0")
BASEDIR=$(dirname $ThisScriptDir)
echo "Here is your script directory: $BASEDIR"
. $BASEDIR/$EnvFileToUse
echo "$ThisScriptName $RemoteSybaseHost"
echo "$ThisScriptName $RemoteSybaseIP"
####Check to see if the Sybase file transfer for this specific instance is currently running.
####If it is runing, there is nothing to do. If it is NOT running call /LMSybLogRefresh.sh to start it up.
HowManyActivePulls=0
IsPullRunning=$(ps -aux | grep "ssh logicmonc@$RemoteSybaseHost" | grep $OriginalSybaseRepServerLogName | grep -v grep | wc -l)
echo "IsPullRunning: $IsPullRunning"
if [ $IsPullRunning -gt $HowManyActivePulls ]
then
        echo "Sybase Replication Error Log Transfer is active"
else
	echo "================YES we need to START UP the REP log message pulls!"
#        . $BASEDIR/LMSybLogRefresh.sh $EnvFileToUse REP
         . $BASEDIR/LMSybLogRefresh.sh $EnvFileToUse REP
fi
echo "===========Goodbye FROM PullRepServerLog.sh======================================"
