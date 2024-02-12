#!/bin/bash

# Set the disk usage threshold (in percentage)
THRESHOLD=10

# Main loop to check disk usage continuously
while true; do
    # Check disk usage and extract the percentage
    USAGE=$(df -h | grep '/dev/xvd' | head -1 | awk '{print $5}' | sed 's/%//g')
    
    # Check if disk usage exceeds the threshold
    if [[ $USAGE -ge $THRESHOLD ]]; then
        # Send email notification if threshold is reached
        echo "Disk usage threshold reached ($USAGE%)" | mail -s "Disk Usage Warning !!!" -a sagargowda666@gmail.com
    fi
    
    # Sleep for 30 seconds before checking again
    sleep 30
done
