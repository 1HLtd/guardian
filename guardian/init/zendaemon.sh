#!/bin/bash
########################################################
#
#  Guardian init script for start/restart of zendaemon
#
########################################################

# return codes
# 0 - success
# 1 - unable to start
# 2 - wrong configuration
# 3 - configuration file missing

zend_path=/usr/local/sitezen/prd
version='0.2'

killall -9 zendaemon
if ( $zend_path/zendaemon START >/dev/null 2>&1 ); then
   	exit 0
else
   	exit 1
fi
