#!/bin/ksh
##################################################################################
# 
# Desc: This script cleans up the Sybase Error Logs directory and pkill(s) all logicmonc processes
#       The script accepts 2 parameters. The name of the environment file and a number. The number
#       represents the amount of free disk space in MB which must always be available. The special 
#       value of 0 serves as a flag to tell the script to clean up all of the disk space even if
#       the amount of free space > 200 MB
# Author: Will Landstrom-Spinnaker Support
# Date: 7-17-2023
# Version: 1.01
#set -xv
## 
##################################################################################
echo "===========Welcome to CleanupSybaseLMLogs.sh======================================"
display_usage()
{
        echo "This script requires 2 parameters, the name of the associated env file and an integer representing an amount of MB to check"
        echo -e "\nUsage : $0 [arguments] \n"
}
if [ $# -lt 2 ]
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
###. /home/logicmonc/scripts/$EnvFileToUse
NumToCompare=$2
echo "Script Name: $ThisScriptName EnvFile: $EnvFileToUse MBValueToCheck: $NumToCompare"
FilesToDelete=$(ls -al $LogicMonitorSybaseLogDir)
##AvailMBSpace=$(df -m $LogicMonitorSybaseLogDir | awk '{print $4}' | grep -iv avail| rev | cut -c2- | rev)
AvailMBSpace=$(df -m $LogicMonitorSybaseLogDir | awk '{print $4}' | grep -iv avail)
Last_Ret_Code=$?
echo "Last return code: $Last_Ret_Code"
if [ $Last_Ret_Code -eq 0 ]
then
	echo "Dir Space check successfull"
else
	AvailMBSpace=0
	echo "Sybase LM Log space LOW: We need to delete files"
fi

echo "Available space in MB: $AvailMBSpace"

if [ $AvailMBSpace -lt $NumToCompare ]
then
	echo "Sybase LM Log space LOW, deleting files"
	echo "$FilesToDelete"
	rm -rf $LogicMonitorSybaseLogDir/*.*
	pkill -u logicmonc
	pkill -u logicmonc
	pkill -u logicmonc
else
    if [ $NumToCompare -eq 0 ]
    then
        echo "User has indicated that we need to cleanup the LM directory"
        echo "$FilesToDelete"
        rm -rf $LogicMonitorSybaseLogDir/*.*
        pkill -u logicmonc
        pkill -u logicmonc
        pkill -u logicmonc
    else
	echo "Space is ok!"
    fi
fi

echo "===========Goodbye from CleanupSybaseLMLogs.sh======================================"
