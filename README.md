# About
This is a simple bash script for an alarm to check for unexpectedly high cpu tempratures.

With this file you won't have to regularly check for cpu temps and will be notified for any spike in it.

--------------------------
# How to use.

1. I am using lm-sensors program to get cpu-temprature. You can also use any other program to get it. To install lm-sensors use the following command.
	$ sudo apt install lm-sensors		# in debian based software

	# You might also want to check out github repository of lm-sensor
2. Modify line 56 to get float value of your CPU temprature.
3. You might also want to modify $LOGDIR or other two variables.
	NOTE: you must also modify the same on the kill_cpu_temp_alarm.sh file for the values you have changed in cpu_temp_alarm.sh file.
4. You can now run this using the following command
	$ sudo /path/to/file/cpu_temp_alarm.sh
	NOTE: sudo is used in this case because without it we cannot modify the log files at /var/log/cpu_temp_alarm/
 
