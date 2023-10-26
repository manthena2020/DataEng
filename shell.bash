TO RESTART ALL AGENTS IN THE SERVER 
------------------------------------------------------------------------------------------------------------------------
#!/bin/bash

# Set Cloudera Manager login credentials
CM_USERNAME=cloudera
CM_PASSWORD=cloudera

# Get list of all hosts in the cluster
hosts=$(curl -u $CM_cloudera:$CM_cloudera http://localhost:7180/api/v19/hosts | jq -r '.items[].hostId')

# Restart the agent on each host
for host in $hosts
do
  echo "Restarting agent on host $host"
  curl -u $CM_cloudera:$CM_cloudera -X POSThttp://localhost:7180/api/v19/hosts/$host/commands/restartAgent
sleep 5 # wait for 5 seconds before restarting the next agent
Done
------------------------------------------------------------------------------------------------------------------------
#!/bin/bash

# Set Cloudera Manager login credentials
CM_USERNAME=cloudera
CM_PASSWORD=cloudera

# Get list of all hosts in the cluster
hosts_json=$(curl -u $CM_cloudera:$CM_cloudera http://localhost:7180/api/v19/hosts)
hosts=$(echo $hosts_json | awk -F 'hostId' '{for(i=1;i<=NF;i++){if($i==":"){print $(i+1)}}}' | tr -d '",')

# Restart the agent on each host
for host in $hosts
do
  echo "Restarting agent on host $host"
  curl -u $CM_cloudera:$CM_cloudera -X POST http://localhost:7180/api/v19/hosts/$host/commands/restartAgent
  sleep 5 # wait for 5 seconds before restarting the next agent
Done
------------------------------------------------------------------------------------------------------------------------
TO  Stop agents in cluster
------------------------------------------------------------------------------------------------------------------------
#!/bin/bash
#set Cloudera Manager login credentials
CM_USERNAME=cloudera
CM_PASSWORD=cloudera

# Restart all agents in the cluster
echo $CM_cloudera | service cloudera-scm-agent restart --username $CM_cloudera


TO STOP PARTICULAR AGENTS in cluster

# Set Cloudera Manager login credentials
CM_USERNAME=admin
CM_PASSWORD=admin

# File containing the list of hosts you want to restart
hosts_file="hosts.txt"

# Read the file and restart the agents on each host
while read host; do
    echo "Restarting agent on host $host"
    echo $CM_PASSWORD | service cloudera-scm-agent stop --host $host --username $CM_USERNAME
    echo $CM_PASSWORD | service cloudera-scm-agent start --host $host --username $CM_USERNAME
done < $hosts_file


Sure, here is an example of the contents of the hosts.txt file that you can use to stop and start agents on cn3, cn6, and cn7:

Copy code
cn3 cn6 cn7
------------------------------------------------------------------------------------------------------------------------
TO STOP  AGENTS in cluster ( HOSTS MENTIONED IN FILE)*****
------------------------------------------------------------------------------------------------------------------------
#!/bin/bash

# File containing the list of hosts you want to restart
host="hosts.txt"

for host in $(cat $host); do
 echo "Restarting agent on host $host"
ssh $host sudo systemctl stop cloudera-scm-agent
ssh $host sudo systemctl start cloudera-scm-agent

if [ $? -eq 0 ]; then
        echo "Agent restarted successfully on host $host"
    else
        echo "Error: Agent restart failed on host $host"
    fi


done < $host

Wait
------------------------------------------------------------------------------------------------------------------------
TO STOP  AGENTS in cluster ( HOSTS NAME INPUT THRU CLI) ****
------------------------------------------------------------------------------------------------------------------------
#!/bin/bash




# File containing the list of hosts you want to restart

hosts=("$@")

for host in ${hosts[@]}; do

 echo "Restarting agent on host $host"
ssh $host sudo systemctl stop cloudera-scm-agent
ssh $host sudo systemctl start cloudera-scm-agent

if [ $? -eq 0 ]; then
        echo "Agent restarted successfully on host $host"
    else
        echo "Error: Agent restart failed on host $host"
    fi


done

wait
------------------------------------------------------------------------------------------------------------------------
 EMAIL ALERT OF DU -h 
------------------------------------------------------------------------------------------------------------------------

#!/bin/bash

# Set email recipient
RECIPIENT="your_email@example.com"

# List of all hosts in the cluster
hosts=("cn1" "cn2" "cn3" "cn4")

#Initializing an empty variable
email_body=""

# Run du -h on each host
for host in ${hosts[@]}; do
    echo "Running du -h on host $host"
    # Appending the output of command to the email_body variable
    email_body+=$(ssh $host "du -h")
    email_body+=$'\n'
done

# Send email with the output
echo "$email_body" | mail -s "du -h results for entire cluster" "$RECIPIENT"
------------------------------------------------------------------------------------------------------------------------
#!/bin/bash

hosts=("cmg" "cn1" "cn2")

echo "Disk usage:"

for host in "${hosts[@]}"
do
    ssh $host "df -h"
    echo ""
done

echo "Summary for all hosts:"
echo "`df -h | grep '^/dev/' | awk '{ total += $2 } END { print "Total Size: " total }'`  `df -h | grep '^/dev/' | awk '{ total += $3 } END { print "Used Size: " total }'`  `df -h | grep '^/dev/' | awk '{ total += $4 } END { print "Available Size: " total }'`"
------------------------------------------------------------------------------------------------------------------------
#!/bin/bash

hosts=("cmg" "cn1" "cn2")

echo "Disk usage:"

for host in "${hosts[@]}"
do
    ssh $host "df -h" > $host.txt
    echo ""
done

echo "Summary for all hosts:"
echo "Total Size: `awk '{ total += $2 } END { print total }' cmg.txt cn1.txt cn2.txt`"
echo "Used Size: `awk '{ total += $3 } END { print total }' cmg.txt cn1.txt cn2.txt`"
echo "Available Size: `awk '{ total += $4 } END { print total }' cmg.txt cn1.txt cn2.txt`"
------------------------------------------------------------------------------------------------------------------------
#!/bin/bash

hosts=("cmg" "cn1" "cn2")

echo "Disk usage:"

for host in "${hosts[@]}"
do
    ssh $host "df -h"
    echo ""
done

echo "Summary for all hosts:"
echo "`df -h | grep '^/dev/' | awk '{ total += $2 } END { print "Total Size: " total }'`  `df -h | grep '^/dev/' | awk '{ total += $3 } END { print "Used Size: " total }'`  `df -h | grep '^/dev/' | awk '{ total += $4 } END { print "Available Size: " total }'`"

echo "Summary file system wise:"
echo "`df -h | awk '{print $1 " " $2 " " $3 " " $4}'`"
------------------------------------------------------------------------------------------------------------------------

#!/bin/bash( Final version) summary of file system (******)
------------------------------------------------------------------------------------------------------------------------
hosts=("cmg" "cn1" "cn2")

echo "Disk usage:"

for host in "${hosts[@]}"
do
    ssh $host "df -hP | column -t"
    echo ""
done

echo "Summary for all hosts:"
echo "`df -hP | grep '^/dev/' | awk '{ total += $2 } END { print "Total Size: " total }'`  `df -hP | grep '^/dev/' | awk '{ total += $3 } END { print "Used Size: " total }'`  `df -hP | grep '^/dev/' | awk '{ total += $4 } END { print "Available Size: " total }'`"
echo "File System    Total Size    Used Size    Available Size"
df -h | grep '^/dev/' | awk '{print $1 "\t\t" $2 "\t\t" $3 "\t\t" $4}'
------------------------------------------------------------------------------------------------------------------------
file list 
______________________________________________________________________________
#!/bin/bash

echo "-------------Files less than 10 MB-----------------------------------------------------------:"
find . -type f -size -10M -exec ls -lh {} \; | awk '{ print $5 ": " $9 }'

echo "------------------------Files between 11 MB and 64 MB----------------------------------------:"
find . -type f -size +10M -a -size -64M -exec ls -lh {} \; | awk '{ print $5 ": " $9 }'

echo "------------------------Files between 65 MB and 128 MB---------------------------------------:"
find . -type f -size +64M -a -size -128M -exec ls -lh {} \; | awk '{ print $5 ": " $9 }'

echo "------------------------Files greater than 128 MB--------------------------------------------:"
find . -type f -size +128M -exec ls -lh {} \; | awk '{ print $5 ": " $9 }'
____________________________________________________________________________________________________


