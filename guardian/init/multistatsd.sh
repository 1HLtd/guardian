#!/bin/bash
########################################################
#
#  Guardian init script for start/restart of multistatsd
#
########################################################

# return codes
# 0 - success
# 1 - unable to start
# 2 - wrong configuration
# 3 - configuration file missing

program='/usr/local/1h/sbin/multistatsd.pl'
pidfile='/usr/local/1h/var/run/multistatsd.pid'

if [ -f $pidfile ]; then
	multistatsd_pid=$(<$pidfile)
	if [ "$1" == 'restart' ]; then
		pid=$(<$pidfile)
		if [ -d /proc/$pid ]; then
			kill -15 $pid
		fi
		# Do not remove the escapes from \\[multistatsd\\] or bad things will happen!!!
		# You have been warned
		pkill -9 -f \\[Multistatsd\\]
		rm -f $pidfile
	fi
fi

if [ -x $program ]; then
	$program
else
   	exit 2
fi
