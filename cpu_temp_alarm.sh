#!/bin/bash

# Setting respective file locations
SCRIPTDIR="$(cd "$(dirname "$0")" && pwd)"
SOUNDDIR="/home/vaibhav/.cpu_temp_alarm/sounds"
LOGDIR="/var/log/cpu_temp_alarm"

mkdir -p "$LOGDIR"

# Check if cpu_temp_alarm.pid file exists
# If it exists then this file is already running.
if [ -f "$LOGDIR/cpu_temp_alarm.pid" ]; then
	echo $(date) "CPU temprature alarm script is already running!" >> "$log_file"
	echo "CPU temprature alarm script is already running!"
	echo "Please run the kill_cpu_temp_alarm.sh file with the following command to kill that process."
	echo -e "\t$ \"$SCRIPTDIR/kill_cpu_temp_alarm.sh\""
	# or you can also delete the cpu_temp_alarm.pid file located at $LOGDIR
	exit 1
fi

# Set the threshold temperature
threshold_0=75
threshold_1=80
threshold_2=85
threshold_3=90
threshold_4=95

# Set initial wait time to check again
wait_time=300

# Alert Sound files
low_alert="$SOUNDDIR/low-alert.wav"
medium_alert="$SOUNDDIR/medium-alert.wav"
high_alert="$SOUNDDIR/high-alert.wav"

# Set log file path and clear it
log_file="$LOGDIR/cpu_temp_alarm.log"
echo $(date) "CPU temprature moniter started!" > "$log_file"

# Set pid file path
pid_file="$LOGDIR/cpu_temp_alarm.pid"

# Function to print temprature, play alert sound, and change $wait_time
function func1() { 
	echo $(date) "CPU temperature is $1 $2°C! Current temperature: $3°C" >> "$log_file"
	if [ $# -eq "4" ]; then
		wait_time=$4
	elif [ $# -eq "5" ]; then
		apaly $4
		wait_time $5
	fi
}

while true; do
	# Get the CPU temperature using sensors
	cpu_temp=$(sensors | awk '/Tctl/ {gsub(/[+°C]/,"",$2); printf "%.0f", $2}')

	# Check if the temperature exceeds the threshold
	if [ ! -z "$cpu_temp" ]; then
		if [ "$cpu_temp" -gt "$threshold_4" ]; then
			func1 "above" $threshold_4 $cpu_temp $high_alert "600"
			exit 0
		elif [ "$cpu_temp" -gt "$threshold_3" ]; then
			func1 "above" $threshold_3 $cpu_temp $medium_alert "10"
		elif [ "$cpu_temp" -gt "$threshold_2" ]; then
			func1 "above" $threshold_2 $cpu_temp $medium_alert "30"
		elif [ "$cpu_temp" -gt "$threshold_1" ]; then
			func1 "above" $threshold_1 $cpu_temp $low_alert "60"
		elif [ "$cpu_temp" -gt "$threshold_0" ]; then
			func1 "above" $threshold_0 $cpu_temp $low_alert "150"
		else
			func1 "below" $threshold_0 $cpu_temp "300"
		fi
	else
		echo $(date) "Error: CPU temprature not available!" >> "$log_file"
		wait_time=600
	fi

	# Sleep for $wait_time seconds and then check temp again.
	sleep $wait_time
done &
echo $! > "$pid_file"

