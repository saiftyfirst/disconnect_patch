#! /bin/bash

LOG_DIR=../logs/modem_monitor.log
SHORT_SLEEP=10
LONG_SLEEP=20
ROLLOVER_SIZE=5000000
CONNECTED=1
DISCONNECTED=0

HUAWEI_DEVICE=""

STATUS_TAG="[STATUS]"
ACTION_TAG="[ACTION]"

while :
do
	# log search onset
	if [ -z "$HUAWEI_DEVICE" ]; then
		echo `date`: "$ACTION_TAG Searching for HUAWEI Modem Device..." | tee -a $LOG_DIR
	fi

	# poll for device attachment
	while [ -z "$HUAWEI_DEVICE" ]
	do
		HUAWEI_DEVICE=`lsusb | grep Huawei | cut -d : -f 1 | grep -oP '\d+'`
		sleep $SHORT_SLEEP
	done

	BUS=`echo $HUAWEI_DEVICE | cut -d ' ' -f 1`
	DEVICE=`echo $HUAWEI_DEVICE | cut -d ' ' -f 2`
        echo `date`: "$STATUS_TAG Device found!. BUS: $BUS, DEVICE: $DEVICE" | tee -a $LOG_DIR
       	echo ` date`: "$ACTION_TAG Establishing connetion..." | tee -a $LOG_DIR

	STATE=$DISCONNECTED

	# monitor loop
	while [ -n "$HUAWEI_DEVICE" ]
	do
		# log rollover based on $ROLLOVER_SIZE
		log_size=`du -b $LOG_DIR | tr -s '\t' ' ' | cut -d' ' -f1`
		if [ $log_size -gt $ROLLOVER_SIZE ]; then
			timestamp=`date +%s`
			mv $LOG_DIR $LOG_DIR.$timestamp
			touch $LOG_DIR
		fi

		if ls /sys/class/net/ppp* &> /dev/null; then
			if [ $STATE -eq $DISCONNECTED ]; then
				STATE=$CONNECTED
				echo `date`: "$STATUS_TAG connection established..." | tee -a $LOG_DIR
			fi
		else
			if [ $STATE -eq $CONNECTED ]; then
				STATE=$DISCONNECTED
				echo `date`: "$STATUS_TAG connection lost..." | tee -a $LOG_DIR
				echo `date`: "$ACTION_TAG executing disconnect fix/patch until reconnection..." | tee -a $LOG_DIR
			fi

			usbreset $BUS/$DEVICE &> /dev/null

			if [ $? -eq 0 ]; then
				ifup gprs --force &> /dev/null
				sleep $LONG_SLEEP
			else
				echo `date`: "$STATUS_TAG device missing..." | tee -a $LOG_DIR
				HUAWEI_DEVICE=""
			fi
		fi
	done
done
