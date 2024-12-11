#!/bin/bash

# Setting respective file locations
SCRIPTDIR="$(cd "$(dirname "$0")" && pwd)"
SOUNDDIR="$SCRIPTDIR/sounds"
PIDDIR="/tmp"

# Ensure `sensors` command is available
if ! command -v sensors &>/dev/null; then
    echo "Error: 'sensors' command not found. Please install 'lm-sensors' package." >&2
    exit 1
fi

# Check if script is already running
pid_file="$PIDDIR/cpu_temp_alarm.pid"
if [ -f "$pid_file" ]; then
    echo "CPU temperature alarm script is already running!"
    echo "To stop it, use: $SCRIPTDIR/kill_cpu_temp_alarm.sh"
    exit 1
fi

# Set thresholds and initial wait time
declare -A thresholds=(
    ["low"]=75
    ["medium"]=85
    ["high"]=95
)
declare -A wait_times=(
    ["low"]=300
    ["medium"]=60
    ["high"]=10
)
alert_sounds=(
    ["low"]="$SOUNDDIR/low-alert.wav"
    ["medium"]="$SOUNDDIR/medium-alert.wav"
    ["high"]="$SOUNDDIR/high-alert.wav"
)
wait_time=${wait_times["low"]}

echo "$(date) CPU temperature monitor started!" | logger -t cpu_temp_alarm
echo $$ > "$pid_file"

# Main loop
while true; do
    cpu_temp=$(sensors | awk '/Tctl/ {gsub(/[+°C]/,"",$2); printf "%.0f", $2}')
    if [ -z "$cpu_temp" ]; then
        echo "Error: CPU temperature not available!" | logger -t cpu_temp_alarm
        wait_time=600
    else
        if [ "$cpu_temp" -ge "${thresholds["high"]}" ]; then
            alert_level="high"
            wait_time=${wait_times["high"]}
        elif [ "$cpu_temp" -ge "${thresholds["medium"]}" ]; then
            alert_level="medium"
            wait_time=${wait_times["medium"]}
        elif [ "$cpu_temp" -ge "${thresholds["low"]}" ]; then
            alert_level="low"
            wait_time=${wait_times["low"]}
        else
            alert_level=""
            wait_time=300
        fi

        if [ -n "$alert_level" ]; then
            echo "CPU temperature ${cpu_temp}°C exceeds ${thresholds[$alert_level]}°C (level: $alert_level)." | logger -t cpu_temp_alarm
            if [ -f "${alert_sounds[$alert_level]}" ]; then
                aplay "${alert_sounds[$alert_level]}" &
            fi
        fi
    fi
    sleep "$wait_time"
done

