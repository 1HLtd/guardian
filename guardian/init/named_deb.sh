#!/bin/bash
########################################################
#
#  Guardian init script for start/restart of named
#
########################################################

# return codes
# 0 - success
# 1 - unable to start
# 2 - configuration file is broken
# 3 - bind and named users are missing

version='0.0.3'

if ( ! /usr/sbin/named-checkconf >/dev/null 2>&1 ); then
	exit 2
fi

killall -9 named >/dev/null 2>&1

named_user=$(awk -F : '/^(named|bind):/{print $1; exit;}' /etc/passwd)
if [ -z "${named_user}" ]; then
	exit 3
fi

if ( /usr/sbin/named -u "${named_user}" >/dev/null 2>&1 ); then
	exit 0
else
	exit 1
fi

exit 0
