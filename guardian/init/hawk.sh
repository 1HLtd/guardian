#!/bin/bash
########################################################
#
#  Guardian init script for start/restart of Hawk
#
########################################################

# return codes
# 0 - success
# 1 - unable to start
# 2 - wrong configuration
# 3 - configuration file missing

#for i in $(pgrep -f Hawk); do
#	kill -9 $i
#done
pkill -f Hawk
/usr/local/1h/sbin/hawk.pl
