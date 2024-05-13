#!/bin/bash

# Set LOGDIR (where log files and pid files are stored.)
LOGDIR="/var/log/cpu_temp_alarm"

# Set log file path
log_file="$LOGDIR/cpu_temp_alarm.log"

# Set PID file path
pid_file="$LOGDIR/cpu_temp_alarm.pid"

# Check if the PID file exists
if [ -f "$pid_file" ]; then
	# Read the PID from the file
	pid=$(cat "$pid_file")
	
	# Kill the process
	kill $pid

	# Remove the pid file
	rm "$pid_file"
	echo $(date) "CPU temprature alarm process killed!" >> "$log_file"
else
	echo $(date) "CPU temprature alarm process is not running." >> "$log_file"
fi
