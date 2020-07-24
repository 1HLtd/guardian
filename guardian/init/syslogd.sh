#!/bin/bash

########################################################
#
#  Guardian init script for start/restart of syslogd
#
########################################################
# return codes
# 0 - success
# 1 - unable to start

pidfile='/var/run/syslogd.pid'

if [ "$1" == 'restart' ]; then
	if [ -f $pidfile ] && [ -d /proc/$(<$pidfile) ]; then
		/bin/kill -9 $(<$pidfile) > /dev/null 2>&1
	fi
fi

if ( ! /sbin/syslogd -m 0 > /dev/null 2>&1 ); then
	exit 1
fi

if [ ! -f $pidfile ] || [ ! -d /proc/$(<$pidfile) ]; then
	exit 1
fi

exit 0
