#!/bin/bash

# Prompt user to enter the PID (enter blank to enter command)
read -p "Enter the Process ID: " PROCESS_ID

# Prompt user to enter the command
read -p "Enter the command: " COMMAND

# Generate timestamp for the output filename
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")


if [[ -z $PROCESS_ID ]]; then
    ps aux | grep "$COMMAND" | head -1 | awk '{print "PID:", $2 , "\tCPU:", $3 , "\tMEM:" , $4 , "\tCMD:" , $11}' > resource_${TIMESTAMP}.txt
else 
    ps aux | grep "$PROCESS_ID" | head -1 | awk '{print "PID:", $2 , "\tCPU:", $3 , "\tMEM:" , $4 , "\tCMD:" , $11}' > resource_${TIMESTAMP}.txt
fi
