#! /bin/bash

SOURCE=$(dirname "$0")

cp $SOURCE/modem_monitor.sh /usr/bin/
cp $SOURCE/modem_monitor.service /etc/systemd/system/

systemctl enable modem_monitor

reboot now
