#! /bin/bash

LOG_DIR=/var/log/modem_monitor.log

REBOOT_LIMIT=15

echo `date`: 'Monitor started...' | tee -a $LOG_DIR
echo `date`: 'Reboot limit set at ' $REBOOT_LIMIT | tee -a $LOG_DIR

reboot_counter=0
while :
do
	if ls /sys/class/net/ppp* 1> /dev/null 2>^1; then
		echo `date`: 'connection active...' | tee -a $LOG_DIR
	else
		if [[ "$reboot_counter" -eq "$REBOOT_LIMIT" ]]; then
			echo `date`: 'rebooting system...' | tee -a $LOG_DIR
			sleep 2
			reboot now
		fi
		echo `date`: 'connection lost... Incrementing reboot counter.' | tee -a $LOG_DIR
		ifdown gprs &> /dev/null
		sleep 2
		ifup gprs &> /dev/null
		echo `date`: 'attempting reconnection...' | tee -a $LOG_DIR
		reboot_counter=$((reboot_counter+1))
	fi

	sleep 20
done
