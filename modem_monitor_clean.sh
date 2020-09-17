#! /bin/bash

LOG_DIR=/var/log/modem_monitor.log
ERR_LOG_DIR=/var/log/modem_monitor_errs.log
HUAWEI_DEVICE=""

while :
do
	while [ -z "$HUAWEI_DEVICE" ]
	do
		echo `date`: "Searching for HUAWEI Modem Device..." | tee -a $LOG_DIR
		HUAWEI_DEVICE=`lsusb | grep Huawei | cut -d : -f 1 | grep -oP '\d+'`
		sleep 20
	done


	BUS=`echo $HUAWEI_DEVICE | cut -d ' ' -f 1`
	DEVICE=`echo $HUAWEI_DEVICE | cut -d ' ' -f 2`
        echo `date`: "Device found!. BUS: $BUS, DEVICE: $DEVICE" | tee -a $LOG_DIR

       	echo ` date`: 'Start monitoring...' | tee -a $LOG_DIR

	while [ -n "$HUAWEI_DEVICE" ]
	do
		if ls /sys/class/net/ppp* 1> /dev/null; then
			echo `date`: 'connection active...' | tee -a $LOG_DIR
		else
			echo `date`: 'connection inactive...' | tee -a $LOG_DIR $ERR_LOG_DIR

			if ! ls /dev/ttyUSB0 &> /dev/null; then
				echo `date`: 'ttyUSB0 missing...' | tee -a $LOG_DIR $ERR_LOG_DIR
			fi
                        echo `date`: 'attempting usbreset...' | tee -a $LOG_DIR $ERR_LOG_DIR
			usbreset $BUS/$DEVICE

			if [ $? -eq 0 ]; then
				echo `date`: 'successfully rebooted' | tee -a $LOG_DIR
				echo `date`: 'ifup gprs forced reconfigure and wait started...'
				ifup gprs --force
				sleep 45
				echo `date`: 'ifup gprs forced...' | tee -a $LOG_DIR
			else
				echo `date`: 'device missing...' | tee -a $LOG_DIR $ERR_LOG_DIR
				HUAWEI_DEVICE=""
			fi
		fi
		sleep 20
	done
done
