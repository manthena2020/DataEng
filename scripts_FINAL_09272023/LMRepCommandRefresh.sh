#!/bin/ksh
##################################################################################
#
# Desc: This script ensures that the latest Rep Command logs are being pulled.
#       These logs are ADMINHEALTH,ADMINWHOISDOWN,ADMINWHOSQT,ADMINWHOSQM,ADMINDISKSPACE
# NOTE(s) - this is a CALLED module (a submodule). It is called from
#       PullRepAdminHealthLogs.sh,PullRepAdminWhoIsDownLogs.sh,PullRepAdminWhoSQMLogs.sh,
#       PullRepAdminWhoSQTLogs.sh,PullAdminDiskSpaceLogs.sh
#       Also, unlike the other Sybase/Replication "log pull" scripts this script does NOT need to perform
#       any "last log rec processed" checks becuase the "logs" for the Rep Commands ALWAYS contain new/refreshed data.
# Author: Will Landstrom-Spinnaker Support
# Date: 7-28-2023
# Version: 1.01
#
#set -xv
##
##################################################################################
echo "===========Welcome to LMRepCommandRefresh.sh======================================"
#Step01 - source in the environment file
display_usage()
{
        echo "This script requires 2 parameters, the name of an associated env file and a log type indicator"
        echo -e "\nUsage : $0 [arguments] \n"
}
if [ $# -lt 2 ]
then
        display_usage
        exit 1
fi

ProcessHealth()
{
        echo "ENTER ProcessHealth!"
	echo "$RepCommandLogDir/$RepAdminHealthLogName"
	ssh $PullLogCronUser@$RemoteRepServerHost tail -f $RepCommandLogDir/$RepAdminHealthLogName >> $LogicMonitorSybaseLogDir/$RepAdminHealthLogName.ForLogicMonitor
	echo "EXIT ProcessHealth!"
}

ProcessWhoIsDown()
{
        echo "ENTER ProcessWhoIsDown!"
	echo "$RepCommandLogDir/$RepAdminWhoIsDownLogName"
        ssh $PullLogCronUser@$RemoteRepServerHost tail -f $RepCommandLogDir/$RepAdminWhoIsDownLogName >> $LogicMonitorSybaseLogDir/$RepAdminWhoIsDownLogName.ForLogicMonitor
        echo "EXIT ProcessWhoIsDown!"
}

ProcessWhoSQT()
{
        echo "ENTER ProcessWhoSQT!"
	echo "$RepCommandLogDir/$RepAdminWhoSQTLogName"
        ssh $PullLogCronUser@$RemoteRepServerHost tail -f $RepCommandLogDir/$RepAdminWhoSQTLogName >> $LogicMonitorSybaseLogDir/$RepAdminWhoSQTLogName.ForLogicMonitor
        echo "EXIT ProcessWhoSQT!"
}

ProcessWhoSQM()
{
        echo "ENTER ProcessWhoSQM!"
	echo "$RepCommandLogDir/$RepAdminWhoSQMLogName"
        ssh $PullLogCronUser@$RemoteRepServerHost tail -f $RepCommandLogDir/$RepAdminWhoSQMLogName >> $LogicMonitorSybaseLogDir/$RepAdminWhoSQMLogName.ForLogicMonitor
        echo "EXIT ProcessWhoSQM!"
}

ProcessDiskSpace()
{
        echo "ENTER ProcessDiskSpace!"
	echo "$RepCommandLogDir/$RepAdminDiskSpaceLogName"
        ssh $PullLogCronUser@$RemoteRepServerHost tail -f $RepCommandLogDir/$RepAdminDiskSpaceLogName >> $LogicMonitorSybaseLogDir/$RepAdminDiskSpaceLogName.ForLogicMonitor
        echo "EXIT ProcessDiskSpace!"
}

#######BEGIN MAIN PROCESSING################
ThisScriptName=$0
EnvFileToUse=$1
SybLogType=$2
ThisScriptDir=$(readlink -f "$0")
BASEDIR=$(dirname $ThisScriptDir)
. $BASEDIR/$EnvFileToUse
echo "OK the script directory is: $BASEDIR"
echo "THe cron user is: $PullLogCronUser"
##BASEDIR=/home/$PullLogCronUser/scripts
TheDate=$(date +"%m-%d-%y-%H-%M-%S-%s")
###. $BASEDIR/$EnvFileToUse

echo "==============================================="
echo "Passed ENV file: $EnvFileToUse  Passed SybLogType: $SybLogType"
echo "These are the Rep Command Driver logs..."
echo $RepCommandLogDir
echo $RepAdminHealthLogName
echo $RepAdminWhoIsDownLogName
echo $RepAdminWhoSQTLogName
echo $RepAdminWhoSQMLogName
echo $RepAdminDiskSpaceLogName

if [ $SybLogType == "ADMINHEALTH" ]
then
    ProcessHealth
else
if [ $SybLogType == "ADMINWHOISDOWN" ]
then
    ProcessWhoIsDown
else
if [ $SybLogType == "ADMINWHOSQT" ]
then
    ProcessWhoSQT
else
if [ $SybLogType == "ADMINWHOSQM" ]
then
    ProcessWhoSQM
else
if [ $SybLogType == "ADMINDISKSPACE" ]
then
    ProcessDiskSpace
else
    echo "Invalid ENV VAR Passed!"
    exit 1
    fi
   fi
  fi
 fi
fi
exit 0
