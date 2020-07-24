#!/bin/bash
########################################################
#
#  Guardian init script for start/restart of dovecot
#
########################################################

# return codes
# 0 - success
# 1 - unable to start
# 2 - wrong configuration
# 3 - configuration file missing
pidfile='/var/run/dovecot/master.pid'

if [ "$1" == 'restart' ]; then
	if [ -f $pidfile ] && [ -d /proc/$(<$pidfile) ]; then
		/bin/kill -9 $(<$pidfile) > /dev/null 2>&1
	fi
fi
/bin/sleep 2
if ( ! /usr/sbin/dovecot > /dev/null 2>&1 ); then
	exit 1
fi
if [ ! -f $pidfile ] || [ ! -d /proc/$(<$pidfile) ]; then
	exit 1
fi
exit 0
