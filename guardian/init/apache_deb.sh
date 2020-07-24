#!/bin/bash
########################################################
#
#  Guardian init script for start/restart of Apache
#
########################################################

VERSION='0.0.4'

# return codes
# 0 - success
# 1 - unable to start
# 2 - wrong configuration
# 3 - configuration file missing
# 4 - apache binary not found
# 5 - apache binary not executable

httpd_path=$(/usr/local/1h/bin/webdetails.sh get_webserver_bin)

if [ -z "${httpd_path}" ]; then
	exit 4
fi

if [ ! -x "${httpd_path}" ]; then
	exit 5
fi

httpd_conf=$(/usr/local/1h/bin/webdetails.sh get_webserver_config)
if [ -z "${httpd_conf}" ]; then
	exit 3
fi

#if ( ! $httpd_path -t ); then
#	echo 'Error in the configuration file!'
#	exit 2
#fi

httpd_basename=$(/usr/local/1h/bin/webdetails.sh get_webserver_binname)
if [ ! -z "${httpd_basename}" ]; then
	# stop lingering http processes bound to ports 80 and 443
	killall -9 "${httpd_basename}" > /dev/null 2>&1

	sleep 0.5

	# kill the remaining http processes
	if ( ps ax | grep -v grep | grep "${httpd_basename}" > /dev/null 2>&1 ); then
		killall -9 "${httpd_basename}" > /dev/null 2>&1
	fi
fi

# Read apache envvars if there are such
apache_coredir=$(/usr/local/1h/bin/webdetails.sh get_webserver_coredir)
if [ ! -z "${apache_coredir}" ] && [ -f "${apache_coredir}/envvars" ]; then
	# Source envvars files if such is found
	. ${apache_coredir}/envvars
fi

# fix limits 
ulimit -c 0 -n 14335 -u 2000 > /dev/null 2>&1

# Clean semaphores
ipcs -s | awk '/nobody|apache/{print $2}' | xargs ipcrm sem > /dev/null 2>&1

# Start the Apache
if ( ! $httpd_path -DSSL ); then
	exit 1
fi

exit 0
