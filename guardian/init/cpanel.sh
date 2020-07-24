#!/bin/bash
########################################################
#
#  Guardian init script for start/restart of cPanel
#
########################################################

# return codes
# 0 - success
# 1 - unable to start
# 2 - wrong configuration
# 3 - configuration file missing

version='0.2'
cpanel_conf=/var/cpanel/cpanel.config

if [ ! -f $cpanel_conf ]; then
	echo 'No configuration file found!'
	exit 3
fi


kill -9 $(pgrep cpsrvd) $(pgrep cpanellogd)

if ( /usr/local/cpanel/scripts/restartsrv cpanel >/dev/null 2>&1 ); then
    exit 0
else
    exit 1
fi
