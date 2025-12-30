#!/bin/bash
# Define the log file location
LOG=/home/ec2-user/health_log.txt
# Define your backend server IPs
SERVERS=("10.0.1.101" "10.0.1.52" "10.0.1.119")

echo "--- Health Check at $(date) ---" >> $LOG

for ip in "${SERVERS[@]}"; do
    # Check if the server returns a 200 OK status
    if curl -s --head --connect-timeout 2 http://$ip | grep "200 OK" > /dev/null; then
        echo "Server $ip is UP" >> $LOG
    else
        echo "Server $ip is DOWN! Attempting to alert admin..." >> $LOG
    fi
done