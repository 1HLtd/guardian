#!/bin/bash
# return codes
# 0 - success
# 1 - unable to start
# 2 - wrong configuration
# 3 - configuration file missing

pidfile='/usr/local/1h/var/run/lifesigns.pid'
program='/usr/local/1h/sbin/lifesigns'
VERSION='0.1'

kill -9 $(<$pidfile)

if ( $program ); then
	exit 0
else
	exit 1
fi
