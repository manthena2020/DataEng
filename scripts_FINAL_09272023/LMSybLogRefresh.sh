#!/bin/ksh
##################################################################################
# 
# Desc: This script ensures that the latest SYbase Error Log messages (ASE, BKP, and REP)
#       are being pulled. **NOTE - this is a CALLED module (a submodule). It is called from
#       PullSybaseErrorLogNEW.sh, PullSybaseBackupLogNEW.sh, PullRepServerLogNEW.sh
# Author: Will Landstrom-Spinnaker Support
# Date: 7-19-2023
# Note for possible future enhancement. Right now because the Sybase Error Logs are not
# world-writable we cannot write messages from this server (sapmon01prod) into the 
# Sybase Error Logs. If we decide that we need to do that (IE: write a start/end marker)
# we would need to execute the following command AFTER first making the log world-writable
# ssh $PullLogCronUser@$RemoteSybaseHost "echo Hello from sapmon01prod! >> $SybaseErrorLogLocation"
# Version: 1.01
# Change 01.02 8-19-2023 changed tail -f opton to tail -F for the LOG pulls in order to ensure the tail
# continues working even if the file is deleted and recreated
# 
#set -xv
## 
##################################################################################
echo "===========Welcome to LMSybLogRefresh.sh======================================"
#Step01 - source in the environment file
display_usage()
{
	echo "This script requires 2 parameters, the name of an associated env file and a log type indicator (ASE, SYB, or REP)"
        echo -e "\nUsage : $0 [arguments] \n"
}
if [ $# -lt 2 ]
then
        display_usage
        exit 1
fi

ProcessASE()
{
        echo "ENTER ProcessASE!"
	NewASELog=N
	WCSybaseErrorLog=$(ssh $PullLogCronUser@$RemoteSybaseHost wc -l  $SybaseErrorLogLocation | awk '{print $1}')
	if [ -e $LogicMonitorSybaseLogDir/$OriginalSybaseErrorLogName.ForLogicMonitor ]
        then
          DeltaLinesToSkip=$(wc -l $LogicMonitorSybaseLogDir/$OriginalSybaseErrorLogName.ForLogicMonitor | awk '{print $1}')
	  tail -1 $LogicMonitorSybaseLogDir/$OriginalSybaseErrorLogName.ForLogicMonitor > $LogicMonitorSybaseLogDir/LastRec.$OriginalSybaseErrorLogName.ForLogicMonitor
        else
          DeltaLinesToSkip=0
          echo "EMPTYEMPTYEMPTY" > $LogicMonitorSybaseLogDir/LastRec.$OriginalSybaseErrorLogName.ForLogicMonitor
        fi
	##experiment WNL echo $DeltaLinesToSkip > $BASEDIR/WC.$SybLogType.$EnvFileToUse.ForLogicMonitor
        echo $DeltaLinesToSkip > $LogicMonitorSybaseLogDir/WC.$SybLogType.$EnvFileToUse.ForLogicMonitor
	####Check to  see if we have a NEWLY created ASE Error Log. This can be determined in a number of ways, as follows:
	####Check 01 - No WC file means a new ASE log
	if [ ! -f $LogicMonitorSybaseLogDir/WCPREV.$OriginalSybaseErrorLogName ]
	then
          echo $WCSybaseErrorLog > $LogicMonitorSybaseLogDir/WCPREV.$OriginalSybaseErrorLogName
          NewASELog=Y
	else
          ####Check 02 - A current WC count < PREV WC count means a new ASE log
          PREV_WCSybaseErrorLog=$(cat $LogicMonitorSybaseLogDir/WCPREV.$OriginalSybaseErrorLogName)
	  if [ $WCSybaseErrorLog -lt $PREV_WCSybaseErrorLog ]
          then
	     echo $WCSybaseErrorLog > $LogicMonitorSybaseLogDir/WCPREV.$OriginalSybaseErrorLogName
	     NewASELog=Y
          else
	  ####Check 03 - Final check(redundant but executed for abundance of caution) - see if last saved LM rec exists in ASE log
	    LastRecGrepCheck01=$(cat $LogicMonitorSybaseLogDir/LastRec.$OriginalSybaseErrorLogName.ForLogicMonitor | awk '{print $1}') 
	    LastRecGrepCheck02=$(cat $LogicMonitorSybaseLogDir/LastRec.$OriginalSybaseErrorLogName.ForLogicMonitor | awk '{print $2}')
	    echo "This is what we are grepping on: $LastRecGrepCheck01 and $LastRecGrepCheck02"
	    if [ $LastRecGrepCheck01 == "EMPTYEMPTYEMPTY" ]  
            then
              echo "We have no prior Last Rec for Logic Monitor to grep for. This implies a NEW ASE log!"
	      NewASELog=Y
	    else
           ####Lets grep for last Logic Monitor record in the CURRENT ASE log
	      GrepResult=$(ssh $PullLogCronUser@$RemoteSybaseHost grep $LastRecGrepCheck01 $SybaseErrorLogLocation | grep $LastRecGrepCheck02)
	      echo "GrepResult: $GrepResult"
	      echo "NOW WE check the GrepResult"
####If we do NOT find the last saved ASE Log record in the CURR ASE log that implies we have a new ASE log
              if [ -z "$GrepResult" ]
	      then
	        echo "We did not find the last record saved in current ASE log, so we have a new ASE log"
		NewASELog=Y
              else
	        echo "Last saved ASE Error Log record found in CURR ASE log! We do NOT have a new ASE log!"
	      fi
            fi
          fi
	fi
	
	echo "Do we have a new ASE Log? $NewASELog"

	if [ $NewASELog == "Y" ]
	then
	  echo "Perform NEW ASE log pull logic"
	  TailCommandOffSet=$WCSybaseErrorLog
          ssh $PullLogCronUser@$RemoteSybaseHost tail -F -n +$TailCommandOffSet $SybaseErrorLogLocation >> $LogicMonitorSybaseLogDir/$OriginalSybaseErrorLogName.ForLogicMonitor
	else
       	  echo "Perform NOT-NEW ASE log pull logic"
	  TailCommandOffSet=$(($DeltaLinesToSkip + $WCSybaseErrorLog))
	  ssh $PullLogCronUser@$RemoteSybaseHost tail -F -n +$TailCommandOffSet $SybaseErrorLogLocation >> $LogicMonitorSybaseLogDir/$OriginalSybaseErrorLogName.ForLogicMonitor
	fi

	 echo "EXIT ProcessASE!"
}

ProcessBKP()
{
        echo "ENTER ProcessBKP!"
        NewBKPLog=N
        WCSybaseBackupLog=$(ssh $PullLogCronUser@$RemoteSybaseHost wc -l  $SybaseBackupLogLocation | awk '{print $1}')
        if [ -e $LogicMonitorSybaseLogDir/$OriginalSybaseBackupLogName.ForLogicMonitor ]
        then
          DeltaLinesToSkip=$(wc -l $LogicMonitorSybaseLogDir/$OriginalSybaseBackupLogName.ForLogicMonitor | awk '{print $1}')
          tail -1 $LogicMonitorSybaseLogDir/$OriginalSybaseBackupLogName.ForLogicMonitor > $LogicMonitorSybaseLogDir/LastRec.$OriginalSybaseBackupLogName.ForLogicMonitor
        else
          DeltaLinesToSkip=0
          echo "EMPTYEMPTYEMPTY" > $LogicMonitorSybaseLogDir/LastRec.$OriginalSybaseBackupLogName.ForLogicMonitor
        fi
        ##experiment WNL echo $DeltaLinesToSkip > $BASEDIR/WC.$SybLogType.$EnvFileToUse.ForLogicMonitor
	echo $DeltaLinesToSkip > $LogicMonitorSybaseLogDir/WC.$SybLogType.$EnvFileToUse.ForLogicMonitor
        ####Check to  see if we have a NEWLY created BKP Error Log. This can be determined in a number of ways, as follows:
        ####Check 01 - No WC file means a new BKP log
        if [ ! -f $LogicMonitorSybaseLogDir/WCPREV.$OriginalSybaseBackupLogName ]
        then
          echo $WCSybaseBackupLog > $LogicMonitorSybaseLogDir/WCPREV.$OriginalSybaseBackupLogName
          NewBKPLog=Y
        else
          ####Check 02 - A current WC count < PREV WC count means a new BKP log
          PREV_WCSybaseBackupLog=$(cat $LogicMonitorSybaseLogDir/WCPREV.$OriginalSybaseBackupLogName)
          if [ $WCSybaseBackupLog -lt $PREV_WCSybaseBackupLog ]
          then
             echo $WCSybaseBackupLog > $LogicMonitorSybaseLogDir/WCPREV.$OriginalSybaseBackupLogName
             NewBKPLog=Y
          else
          ####Check 03 - Final check(redundant but executed for abundance of caution) - see if last saved LM rec exists in BKP log
	    LastRecGrepCheck01=$(cat $LogicMonitorSybaseLogDir/LastRec.$OriginalSybaseBackupLogName.ForLogicMonitor | awk '{print $1}')
	    LastRecGrepCheck03=$(cat $LogicMonitorSybaseLogDir/LastRec.$OriginalSybaseBackupLogName.ForLogicMonitor | awk '{print $3}')
	    LastRecGrepCheck17=$(cat $LogicMonitorSybaseLogDir/LastRec.$OriginalSybaseBackupLogName.ForLogicMonitor | awk '{print $17}')
	    echo $LastRecGrepCheck03 > $LogicMonitorSybaseLogDir/LastRec03.$OriginalSybaseBackupLogName.ForLogicMonitor
	    echo $LastRecGrepCheck17 > $LogicMonitorSybaseLogDir/LastRec017.$OriginalSybaseBackupLogName.ForLogicMonitor
            if [ $LastRecGrepCheck01 == "EMPTYEMPTYEMPTY" ]
            then
              echo "We have no prior Last Rec for Logic Monitor to grep for. This implies a NEW BKP log!"
              NewBKPLog=Y
            else
	    ##Now check to see of the timestamp and the HostProcid from the current ForLogicMonitor file exists in the active Backup log. If so we can safely
            ##assume we don't have a new BKP Error Log
            ##Lets grep for last Logic Monitor columns 3 and 17 in the CURRENT BKP log
	      GrepResult03=$(ssh $PullLogCronUser@$RemoteSybaseHost grep $LastRecGrepCheck03 $SybaseBackupLogLocation)
              if [ -z "$GrepResult03" ]     
	      then
	        NewBKPLog=Y
              else
                GrepResult17=$(ssh $PullLogCronUser@$RemoteSybaseHost grep $LastRecGrepCheck17 $SybaseBackupLogLocation)
                if [ -z "$GrepResult17" ]	
		then
	  	  echo "We have not found the last saved bkp error log rec in the current sybase bkp file"
	          NewBKPLog=Y
	        else
	          echo "We HAVE found the last saved bkp error log rec in the current sybase bkp file"
                fi
	      fi
            fi
          fi
        fi

        echo "Do we have a new BKP Log? $NewBKPLog"

        if [ $NewBKPLog == "Y" ]
        then
          echo "Perform NEW BKP log pull logic"
          TailCommandOffSet=$WCSybaseBackupLog
          ssh $PullLogCronUser@$RemoteSybaseHost tail -F -n +$TailCommandOffSet $SybaseBackupLogLocation >> $LogicMonitorSybaseLogDir/$OriginalSybaseBackupLogName.ForLogicMonitor
        else
          echo "Perform NOT-NEW BKP log pull logic"
          TailCommandOffSet=$(($DeltaLinesToSkip + $WCSybaseBackupLog))
          ssh $PullLogCronUser@$RemoteSybaseHost tail -F -n +$TailCommandOffSet $SybaseBackupLogLocation >> $LogicMonitorSybaseLogDir/$OriginalSybaseBackupLogName.ForLogicMonitor
        fi

         echo "EXIT ProcessBKP!"
}

ProcessREP()
{
    NewREPLog=N
    WCSybaseRepServerLog=$(ssh $PullLogCronUser@$RemoteRepServerHost wc -l  $SybaseRepServerLogLocation | awk '{print $1}')
    if [ -e $LogicMonitorSybaseLogDir/$OriginalSybaseRepServerLogName.ForLogicMonitor ]
    then
    DeltaLinesToSkip=$(wc -l $LogicMonitorSybaseLogDir/$OriginalSybaseRepServerLogName.ForLogicMonitor | awk '{print $1}')
    tail -1 $LogicMonitorSybaseLogDir/$OriginalSybaseRepServerLogName.ForLogicMonitor > $LogicMonitorSybaseLogDir/LastRec.$OriginalSybaseRepServerLogName.ForLogicMonitor
    else
      DeltaLinesToSkip=0
      echo "EMPTYEMPTYEMPTY" > $LogicMonitorSybaseLogDir/LastRec.$OriginalSybaseRepServerLogName.ForLogicMonitor
    fi
    echo $DeltaLinesToSkip > $LogicMonitorSybaseLogDir/WC.$SybLogType.$EnvFileToUse.ForLogicMonitor
    ####Check to  see if we have a NEWLY created REP Error Log. This can be determined in a number of ways, as follows:
    ####Check 01 - No WC file means a new REP log
    if [ ! -f $LogicMonitorSybaseLogDir/WCPREV.$OriginalSybaseRepServerLogName ]
    then
      echo $WCSybaseRepServerLog > $LogicMonitorSybaseLogDir/WCPREV.$OriginalSybaseRepServerLogName
      NewREPLog=Y
    else
      ####Check 02 - A current WC count < PREV WC count means a new REP log
      PREV_WCSybaseRepServerLog=$(cat $LogicMonitorSybaseLogDir/WCPREV.$OriginalSybaseRepServerLogName)
      if [ $WCSybaseRepServerLog -lt $PREV_WCSybaseRepServerLog ]
      then
         echo "NEW REP WC count LESS THAN OLD COUNT!"
         echo $WCSybaseRepServerLog > $LogicMonitorSybaseLogDir/WCPREV.$OriginalSybaseRepServerLogName
         NewREPLog=Y
      else
##Check 03 - Final check(redundant but executed for abundance of caution) - see if last saved LM rec exists in REP log
        LastRecGrepCheck=$(cat $LogicMonitorSybaseLogDir/LastRec.$OriginalSybaseRepServerLogName.ForLogicMonitor)
        echo "This is what we are grepping on: $LastRecGrepCheck"
        if [ $LastRecGrepCheck == "EMPTYEMPTYEMPTY" ]
        then
          NewREPLog=Y
        else
####Lets grep for last Logic Monitor record in the CURRENT REP log
          GrepResult=$(ssh $PullLogCronUser@$RemoteRepServerHost grep $LastRecGrepCheck $SybaseRepServerLogLocation)
####If we do NOT find the last saved REP Log record in the CURR REP log that implies we have a new REP log
          if [ -z "$GrepResult" ]
          then
            echo "We did not find the last record saved in current REP log, so we have a new REP log"
            NewREPLog=Y
          else
            echo "Last saved REP Error Log record found in CURR REP log! We do NOT have a new REP log!"
          fi
        fi
      fi
    fi

    echo "Do we have a new REP Log? $NewREPLog"

   if [ $NewREPLog == "Y" ]
   then
   TailCommandOffSet=$WCSybaseRepServerLog
#   ssh $PullLogCronUser@$RemoteRepServerHost tail -f -n +$TailCommandOffSet $SybaseRepServerLogLocation >> $LogicMonitorSybaseLogDir/$OriginalSybaseRepServerLogName.ForLogicMonitor
   ssh $PullLogCronUser@$RemoteRepServerHost tail -F -n +$TailCommandOffSet $SybaseRepServerLogLocation >> $LogicMonitorSybaseLogDir/$OriginalSybaseRepServerLogName.ForLogicMonitor
   else
   TailCommandOffSet=$(($DeltaLinesToSkip + $WCSybaseRepServerLog))
#   ssh $PullLogCronUser@$RemoteRepServerHost tail -f -n +$TailCommandOffSet $SybaseRepServerLogLocation >> $LogicMonitorSybaseLogDir/$OriginalSybaseRepServerLogName.ForLogicMonitor
    ssh $PullLogCronUser@$RemoteRepServerHost tail -F -n +$TailCommandOffSet $SybaseRepServerLogLocation >> $LogicMonitorSybaseLogDir/$OriginalSybaseRepServerLogName.ForLogicMonitor
   fi
}


#######BEGIN MAIN PROCESSING################
ThisScriptName=$0
EnvFileToUse=$1
SybLogType=$2
ThisScriptDir=$(readlink -f "$0")
BASEDIR=$(dirname $ThisScriptDir)
echo "Here is your script directory: $BASEDIR"
. $BASEDIR/$EnvFileToUse
TheDate=$(date +"%m-%d-%y-%H-%M-%S-%s")
echo "$ThisScriptName $RemoteSybaseHost"
echo "$ThisScriptName $RemoteSybaseIP"

echo "==============================================="
echo "Passed ENV file: $EnvFileToUse  Passed SybLogType: $SybLogType"

if [ $SybLogType == "ASE" ]
then
	ProcessASE
else
	if [ $SybLogType == "REP" ]
	then
	    ProcessREP
	else
	    if [ $SybLogType == "BKP" ]
	    then
		ProcessBKP
	    else
                echo "Invalid ENV VAR Passed!"
	        exit 1
	    fi
	fi
fi
exit 0
