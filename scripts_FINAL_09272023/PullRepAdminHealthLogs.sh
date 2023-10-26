#!/bin/ksh
##################################################################################
# 
# Desc: This script CALLS the script LMRepCommandRefresh.sh, which performs the actual
#       pulling of the Rep Command Driver logs. The Rep Command Driver script must
#       be running from the crontab on the actual Sybase Replication Server 
#
# Author: Will Landstrom-Spinnaker Support
# Date: 7-28-2023
# Version: 1.01
# set -xv
## 
##################################################################################
echo "===========Welcome to PullRepAdminHealthLogs.sh======================================"
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
###BASEDIR=/home/$PullLogCronUser/scripts
###. $BASEDIR/$EnvFileToUse
ThisScriptDir=$(readlink -f "$0")
BASEDIR=$(dirname $ThisScriptDir)
. $BASEDIR/$EnvFileToUse
echo "OK the script directory is: $BASEDIR"
echo "THe cron user is: $PullLogCronUser"
####Check to see if the Sybase file transfer for this specific instance is currently running.
####If it is runing, there is nothing to do. If it is NOT running call LMRepCommandRefresh.sh to start it up.
MaxAllowedToRun=1
IsPullRunning=$(ps -aux | grep "ssh $PullLogCronUser@$RemoteSybaseHost" | grep $ThisScriptName | grep -v grep | wc -l)
if [ $IsPullRunning -gt $MaxAllowedToRun ]
then
        echo "Sybase Admin Health transfer is active"
else
	echo "================YES we need to START UP the REP Admin Health pulls!"
        . $BASEDIR/LMRepCommandRefresh.sh $EnvFileToUse ADMINHEALTH
fi
echo "===========Goodbye FROM PullRepAdminHealthLogs.sh======================================"
