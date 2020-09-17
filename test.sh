#! /bin/bash

if ! ls /dev/ttyUSB0 &> /dev/null; then
	echo 'Found'
fi
