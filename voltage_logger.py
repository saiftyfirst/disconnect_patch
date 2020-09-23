import sys
import serial
from datetime import datetime

if len(sys.argv) < 3:
	print('Please add device and baudrate as argument')
	sys.exit(0)

#print(sys.argv[1])

ser = serial.Serial(sys.argv[1], sys.argv[2])

with open('voltage.log', 'w') as log:
	while True:
		try:
			raw = ser.readline()
			voltage = raw.decode()
			timestamp = str(datetime.now())
			log_line =  timestamp + ": " + voltage
			print(log_line)
			log.write(log_line)
		except KeyboardInterrupt:
			print('Closing')
			sys.exit()
