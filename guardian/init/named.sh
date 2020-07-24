#!/bin/bash
########################################################
#
#  Guardian init script for start/restart of named
#
########################################################

# return codes
# 0 - success
# 1 - unable to start
# 2 - wrong configuration
# 3 - configuration file missing

named_conf=/etc/named.conf
pid_file=/var/run/named.pid
version='0.3'
options='-n 4'

if [ ! -f $named_conf ]; then
	exit 3;
fi

if ( ! /usr/sbin/named-checkconf >/dev/null 2>&1 ); then
	exit 2;
fi

killall -9 named

if ( /usr/sbin/named -u named $options >/dev/null 2>&1 ); then
	exit 0
else
	exit 1
fi
