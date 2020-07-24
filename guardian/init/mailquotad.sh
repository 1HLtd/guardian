#!/bin/bash
# return codes
# 0 - success
# 1 - unable to start
# 2 - wrong configuration
# 3 - configuration file missing

pidfile='/var/run/mailquotad.pid'
program='/root/admin/mailquotad.pl'
version='0.2'

kill -9 $(<$pidfile)

if ( $program ); then
	exit 0
else
	exit 1
fi

