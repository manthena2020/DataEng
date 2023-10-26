#!/bin/ksh
##################################################################################
# 
# Desc: This script forces a refresh of the log pull processes (pkill(s) all logicmonc processes)
#       The purpose of this script is to avoid excessive 'dead' tail processes
# Author: Will Landstrom-Spinnaker Support
# Date: 8-16-2023
# Version: 1.01
#          1.02 - added change to enable feeding linux crontab user as a passed variable
#set -xv
## 
##################################################################################
echo "===========Welcome to RebootLogPulls.sh======================================"
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
. $BASEDIR/$EnvFileToUse
echo "OK the script directory is: $BASEDIR"
echo "THe cron user is: $PullLogCronUser"
	pkill -u $PullLogCronUser
	pkill -u $PullLogCronUser
	pkill -u $PullLogCronUser
echo "===========Goodbye from RebootLogPulls.sh======================================"
