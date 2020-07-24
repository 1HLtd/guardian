#!/bin/bash
########################################################
#
#  Guardian init script for start/restart of Cron Daemon
#
########################################################

# return codes
# 0 - success
# 1 - unable to start
# 2 - wrong configuration
# 3 - configuration file missing

program='/usr/sbin/crond'
pidfile='/var/run/crond.pid'
version='0.2'

killall -9 crond

if [ -x $program ]; then
	if ( $program ); then
		exit 0
	else
		exit 1
	fi
else
	exit 1
fi
