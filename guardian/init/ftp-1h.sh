#!/bin/bash
########################################################
#
#  Guardian init script for start/restart of Pure-FTPD
#
########################################################

# return codes
# 0 - success
# 1 - unable to start
# 2 - wrong configuration
# 3 - configuration file missing

# Path to the pure-ftp binaries.

ftpd_conf=/etc/pure-ftpd.conf
prog=pure-config.pl
stat=pure-ftpd
fullpath=/usr/sbin/$prog
pureftpwho=/usr/sbin/pure-ftpwho
pureftpauthd=/usr/sbin/pure-authd
auth_pidfile=/var/run/pure-authd.pid
pure_pidfile=/var/run/pure-ftpd.pid

if [ ! -f $ftpd_conf ]; then
	echo 'No configuration file found!'
	exit 3
fi

if [ ! -f $auth_pidfile ]; then
	if [ -f /var/lock/subsys/pure-authd ]; then
		rm -f /var/lock/subsys/pure-authd
	fi
else
	auth_pid=$(<$auth_pidfile)
	if [ "$auth_pid" == '' ] || [ ! -d /proc/$auth_pid ]; then
		rm -f /var/lock/subsys/pure-authd
	fi
fi

if [ ! -f $pure_pidfile ]; then
	if [ -f /var/lock/subsys/$prog ]; then
		rm -f /var/lock/subsys/$prog
	fi
else
	pure_pid=$(<$pure_pidfile)
	if [ "$pure_pid" == '' ] || [ ! -d /proc/$pure_pid ]; then
		rm -f /var/lock/subsys/$prog
	fi
fi

if [ "$1" == 'restart' ]; then
	if ( killall -9 pure-ftpd >/dev/null 2>&1); then
		rm -f /var/lock/subsys/$prog
	fi
	if ( killall -9 pure-authd > /dev/null 2>&1); then
		rm -f /var/lock/subsys/pure-authd
	fi
fi

if [ ! -e /var/lock/subsys/$prog ]; then
	if ( $fullpath $ftpd_conf -O clf:/var/log/xferlog --daemonize > /dev/null 2>&1 ); then
		touch /var/lock/subsys/$prog
	else
		exit 1
	fi
fi

if [ ! -e /var/lock/subsys/pure-authd ]; then
	if ( $pureftpauthd -s /var/run/ftpd.sock -r /usr/sbin/pureauth & > /dev/null 2>&1 ); then
		touch /var/lock/subsys/pure-authd
	else
		exit 1
	fi
fi
