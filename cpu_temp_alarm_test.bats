# cpu_temp_alarm_tests.bats

# Test if the script is executable
@test "Script is executable" {
    run test -x ./cpu_temp_alarm.sh
    [ "$status" -eq 0 ]
}

# Test if PID file is created
@test "Creates PID file" {
    ./cpu_temp_alarm.sh &  # Start the script
    sleep 2                # Allow time for initialization

    # Debugging: Check if PID file exists and log result
    if [ -f /tmp/cpu_temp_alarm.pid ]; then
        echo "PID file found: $(cat /tmp/cpu_temp_alarm.pid)"
    else
        echo "PID file not found!"
        echo "Process status:"
        ps aux | grep -v grep | grep cpu_temp_alarm.sh
        exit 1  # Mark the test as failed
    fi

    # Cleanup
    ./kill_cpu_temp_alarm.sh
}


# Test logger messages
@test "Logger writes messages" {
    ./cpu_temp_alarm.sh &  # Start the script
    pid=$!                 # Capture the PID of the background process
    sleep 5                # Allow time for the script to log

    # Check for the specific log message in the last 2 minutes
    journalctl -t cpu_temp_alarm --since "30 seconds ago" --no-pager | grep -q "CPU temperature monitor started"
    if [ $? -ne 0 ]; then
        echo "Log message not found!"
        echo "Current logs (last 2 minutes):"
        journalctl -t cpu_temp_alarm --since "2 minutes ago" --no-pager
        kill "$pid"
		rm /tmp/cpu_temp_alarm.pid 
        exit 1  # Fail the test
    fi

    # Cleanup
    ./kill_cpu_temp_alarm.sh
}

