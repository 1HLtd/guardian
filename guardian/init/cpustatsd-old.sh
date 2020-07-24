#!/bin/bash
########################################################
#
#  Guardian init script for start/restart of cpustatsd
#
########################################################

# return codes
# 0 - success
# 1 - unable to start
# 2 - wrong configuration
# 3 - configuration file missing

program='/usr/local/1h/sbin/cpustatsd.pl'
pidfile='/usr/local/1h/var/run/cpustatsd.pid'

if [ ! -f $pidfile ]; then
	if [ -f /var/lock/subsys/named ]; then
		rm -f /var/lock/subsys/cpustatsd
	fi
else
	cpustatsd_pid=$(<$pidfile)
	if [ "$cpustatsd_pid" == '' ] || [ ! -d /proc/$cpustatsd_pid ]; then
		rm -f /var/lock/subsys/cpustatsd
	fi
fi

if [ "$1" == 'restart' ]; then
	if [ -f $pidfile ]; then
		pid=$(<$pidfile)
		if [ -d /proc/$pid ]; then
			kill -15 $pid
		fi
		# Do not remove the escapes from \\[cpustatsd\\] or bad things will happen!!!
		# You have been warned
		pkill -9 -f \\[cpustatsd\\]
		rm -f $pidfile
		rm -f /var/lock/subsys/cpustatsd
	fi	
fi

if [ ! -e /var/lock/subsys/cpustatsd ]; then
	if [ -x $program ]; then
    	if ( $program ); then
        	touch /var/lock/subsys/cpustatsd
    	fi
	else
    	exit 2
	fi
else
	exit 1
fi
