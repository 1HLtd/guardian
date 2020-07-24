#!/bin/bash
########################################################
#
#  Guardian init script for start/restart of cpanellogd
#
########################################################

# return codes
# 0 - success
# 1 - unable to start
# 2 - wrong configuration
# 3 - configuration file missing
version='0.2'

killall -9 cpanellogd

if ( /usr/local/cpanel/cpanellogd >/dev/null 2>&1 ); then
	exit 0
else
	exit 1
fi
