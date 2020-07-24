#!/bin/bash
########################################################
#
#  Guardian init script for start/restart of MySQL
#
########################################################

# return codes
# 0 - success
# 1 - unable to start
# 2 - wrong configuration
# 3 - configuration file missing

VERSION='1.0.0'

mysql_conf='/etc/my.cnf'
basedir='/usr'
datadir='/var/lib/mysql'
bindir="$basedir/bin"

timeout=45

mysql_pid=''
mysql_pid_file="$datadir/$(/bin/hostname).pid"

haspid=1
haspid_file=1

if [ ! -f $mysql_conf ]; then
	echo 'No configuration file found!'
	exit 3
fi

# Check if we had existing mysql pid.
if [ ! -f $mysql_pid_file ]; then
	echo "Missing server pid $mysql_pid_file"
	haspid_file=0
	haspid=0
else
	echo "$mysql_pid_file is here"
	mysql_pid=$(<$mysql_pid_file)
	echo "Got mysql pid $mysql_pid"

	# Make sure that the MySQL pid found in the pid file is a valid one
	if [ "$mysql_pid" == '' ] || [ ! -d /proc/$mysql_pid ]; then
		haspid=0
		echo "Empty pid or the pid does not exists in /proc"
	fi
fi

# Wait for $timeout after the kill till the mysql_pid_file dissapear
function wait_stop_pid () {
	while ( test -s $mysql_pid_file ); do
		if [ $timer -eq $timeout ]; then
			return 1
		fi
		let timer=$timer+1
		sleep 1
	done
	return 0
}

# Wait for $timeout after the kill till the pidof mysqld returns is false or timeout
function wait_stop_pidof () {
	while ( pidof mysqld >> /dev/null 2>&1 ); do
		if [ $timer -eq $timeout ]; then
			return 1
		fi
		let timer=$timer+1
		sleep 1
	done
	return 0
}

# Wait for $timeout during the MySQL startup
function wait_start_pid () {
	while ( test ! -s $mysql_pid_file ); do
		if [ $timer -gt $timeout ]; then
			return 1
		fi
		let timer=$timer+1
		sleep 1
	done
	return 0
}

if [ "$1" == 'restart' ]; then
	timer=0
	# If we have a valid proc pid file send normal kill signal and wait till the pidfile dissapear or the check times out
	if [ $haspid -eq 1 ]; then
		echo "We got pidfile $mysql_pid_file as well as a valid mysql pid $mysql_pid"
		kill $mysql_pid
		wait_stop_pid
		return_value=$?
	# If we do not have valid proc pid but the pid file is there use killall mysqld and mysqld_safe and wait till the pidfile
	# dissapear or the check times out
	elif [ $haspid_file -eq 1 ]; then
		echo "We got pidfile $mysql_pid_file but invalid/non-running mysql pid"
		killall mysqld mysqld_safe
		wait_stop_pid
		return_value=$?
	# If we do not have valid proc pid or valid pid file use killall again but wait till the pidof mysqld return false or timeout
	else
		echo "We do not have valid proc pid nor the mysql pid file exists"
		killall mysqld mysqld_safe
		wait_stop_pidof	
		return_value=$?
	fi

	# No matter how all of the above ifs ended make sure that all mysqld and mysqld_safe pids are completely anihilated
	# If some of the ifs above timed out this should do the trick to stop the mysql :)
	# If the ifs shot down the mysql normally this does not affect anything so we consider it safe enough to be used
	killall -9 mysqld
	killall -9 mysqld_safe

	# Just to know what happened
	case "$return_value" in
		"0")
			echo "MySQL pid normal shutdown"
		;;
		"1")
			echo "MySQL pid check timed out. Using kill -9"
		;;
		"2")
			echo "Missing MySQL pid. Using kill -9"
		;;
		*)
			echo "Unknown case while trying to shut down the MySQL ..."	
	esac

	# Remove the lock and the pids no matter what
	rm -f /var/lock/subsys/mysql $mysql_pid_file
fi

if [ ! -e /var/lock/subsys/mysql ]; then
	timer=0
	$bindir/mysqld_safe --defaults-file=$mysql_conf --datadir=$datadir --pid-file=$mysql_pid_file > /dev/null 2>&1 &
	# Wait for $timeout for the mysql pid file to appear
	wait_start_pid
	# If the pid file does not appear for 45 seconds most probbably there is a problem with the mysqld start
	return_value=$?
	touch /var/lock/subsys/mysql
	echo "MySQLD start returned $return_value"
	exit $return_value
else
	echo "MySQLD lock exists. Skipping the start"
	exit 1
fi
