#!/bin/bash
########################################################
#
#  Guardian init script for start/restart of Apache
#
########################################################

VERSION='0.0.6'

# return codes
# 0 - success
# 1 - unable to start
# 2 - wrong configuration
# 3 - configuration file missing

httpd_path='httpd'
if [ -x /usr/local/directadmin/directadmin ]; then
	httpd_path='/usr/sbin/httpd'
elif [ -x /usr/local/cpanel ]; then
	httpd_path='/usr/local/apache/bin/httpd'
fi

if [ ! -f /usr/local/apache/conf/httpd.conf ] && [ ! -f /etc/httpd/conf/httpd.conf ]; then
	echo 'No configuration file found!'
	exit 3;
fi

if ( ! $httpd_path -t ); then
	echo 'Error in the configuration file!'
	exit 2;
fi

# clean queued apache restarts
# to prevent flock wait forever on /var/cpanel/taskqueue/servers_queue.json use timeout
# 2 seconds
#timeout -s 9 2 /usr/local/1h/lib/guardian/fixers/clean_cpanel_task_queue.pl

# Kill all any cpanel restart process that might be running
pkill -9 -f safeapacherestart
pkill -9 -f safeaprestart
pkill -9 -f restartsrv_httpd

# clean queued apache restarts
# to prevent flock wait forever on /var/cpanel/taskqueue/servers_queue.json use timeout
# 5 seconds - wait a bit longer this time
#timeout -s 9 5 /usr/local/1h/lib/guardian/fixers/clean_cpanel_task_queue.pl

# stop lingering http processes bound to ports 80 and 443
killall -9 httpd > /dev/null 2>&1
sleep 0.5

# kill the remaining http processes
if ( ps ax | grep httpd | grep -v grep > /dev/null 2>&1 ); then
	killall -9 httpd > /dev/null 2>&1
fi

# fix limits 
ulimit -c 0 -n 32656 -u 10000 > /dev/null 2>&1

ipcs -s | gawk -F' ' '/nobody|apache/{print $2}' | xargs ipcrm sem > /dev/null 2>&1

# Start the Apache
if ( ! $httpd_path -DSSL ); then
	exit 1
fi

exit 0
