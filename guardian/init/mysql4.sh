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

mysql_conf=/etc/my.cnf
datadir=/var/lib/mysql
bindir=/usr/bin
server_pid_file="$datadir/$(/bin/hostname).pid"
service_startup_timeout=120

if [ ! -f $mysql_conf ]; then
	echo 'No configuration file found!'
	exit 3
fi

if [ ! -f $server_pid_file ]; then
	if [ -f /var/lock/subsys/mysql ]; then
		rm -f /var/lock/subsys/mysql
	fi
else
	mysql_pid=$(<$server_pid_file)
	if [ "$mysql_pid" == '' ] || [ ! -d /proc/$mysql_pid ]; then
		rm -f /var/lock/subsys/mysql
	fi
fi

wait_for_pid () {
	verb="$1"
	manager_pid="$2"  # process ID of the program operating on the pid-file
	i=0
	avoid_race_condition="by checking again"
	while test $i -ne $service_startup_timeout ; do
		case "$verb" in
			'created')
				# wait for a PID-file to pop into existence.
				test -s $server_pid_file && i='' && break
				;;
			'removed')
				# wait for this PID-file to disappear
				test ! -s $server_pid_file && i='' && break
				;;
			*)
				exit 1
				;;
    	esac
		# if manager isn't running, then pid-file will never be updated
		if test -n "$manager_pid"; then
			if kill -0 "$manager_pid" 2>/dev/null; then
				:  # the manager still runs
			else
				# The manager may have exited between the last pid-file check and now.
				if test -n "$avoid_race_condition"; then
					avoid_race_condition=""
					continue  # Check again.
				fi
				# there's nothing that will affect the file.
				return 1  # not waiting any more.
			fi
    	fi
		sleep 1
	done
	if test -z "$i" ; then
		return 0
	else
		return 1
	fi
}

if [ "$1" == 'restart' ]; then
	kill $(<$server_pid_file)
	wait_for_pid removed "$(<$server_pid_file)"; return_value=$?
	rm -f /var/lock/subsys/mysql
fi

if [ ! -e /var/lock/subsys/mysql ]; then
	$bindir/mysqld_safe --datadir=$datadir --pid-file=$server_pid_file >/dev/null 2>&1 &
	wait_for_pid created $!; return_value=$?
	touch /var/lock/subsys/mysql
	exit $return_value
else
	exit 1
fi
