#!/bin/bash
#  Guardian init script for ClamAV start/restart 
# return codes
# 0 - success
# 1 - unable to start

if [ "$1" == 'restart' ]; then
	# kill ClamAV daemon process hard :)
	killall -9 clamd >> /dev/null 2>&1
	# Clanup ClamAV socket
	rm -f /var/clamd
fi

if ( ! /usr/sbin/clamd > /dev/null 2>&1 ); then
	exit 1
fi

exit 0
