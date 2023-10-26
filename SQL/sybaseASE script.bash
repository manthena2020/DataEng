#!/bin/bash

# Define your Sybase server connection details
server_name="system.hostname"
username="sybase.user"
password="sybase.pass"

# Attempt to connect to the Sybase server using isql
if isql -S "$server_name" -U "$username" -P "$password" -b -o /dev/null; then
    echo "status:1" # Server is online
else
    echo "status:0" # Server is offline or connection failed
fi