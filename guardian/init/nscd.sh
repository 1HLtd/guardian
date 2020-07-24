#!/bin/bash
########################################################
#
#  Guardian init script for start/restart of NSCD Daemon
#
########################################################

# return codes
# 0 - success
# 1 - unable to start
# 2 - wrong configuration
# 3 - configuration file missing

nscd_conf=/etc/nscd.conf
VERSION='0.4'

if [ ! -f $nscd_conf ]; then
    echo 'No configuration file found!'
    exit 3
fi

killall -9 nscd
rm -f /chroot/run/nscd/nscd.pid

if ( /usr/sbin/nscd >/dev/null 2>&1 ); then
   	exit 0
else
   	exit 1
fi
