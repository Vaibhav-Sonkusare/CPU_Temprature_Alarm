#!/bin/bash

# Set pid file
pid_file="/tmp/cpu_temp_alarm.pid"

# Check if the PID file exists
if [ -f "$pid_file" ]; then
    pid=$(cat "$pid_file")
    if kill "$pid" &>/dev/null; then
        echo "$(date) CPU temperature alarm process killed!" | logger -t cpu_temp_alarm
        rm "$pid_file"
    else
        echo "$(date) Failed to kill process with PID $pid." | logger -t cpu_temp_alarm
    fi
else
    echo "$(date) No CPU temperature alarm process running." | logger -t cpu_temp_alarm
fi

