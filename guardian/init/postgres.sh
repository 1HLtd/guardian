#!/bin/bash
########################################################
#
#  Guardian init script for start/restart of PostgreSQL
#
########################################################

# return codes
# 0 - success
# 1 - unable to start
# 2 - wrong configuration
# 3 - configuration file missing

pg_bin=/usr/bin
pg_port=5432
pg_data=/var/lib/pgsql/data/
pg_conf=$pg_data/postgresql.conf
pg_log=/var/lib/pgsql/pgstartup.log
pid_file=/var/run/postmaster.5432.pid

if [ ! -f $pg_conf ]; then
	echo 'No configuration file found!'
	exit 3
fi

if [ ! -d "$pg_data/base" ]; then
	exit 2
fi

if [ ! -f $pid_file ]; then
	if [ -f /var/lock/subsys/postgresql ]; then
		rm -f /var/lock/subsys/postgresql
	fi	
else
	pg_pid=$(<$pid_file)
	if [ "$pg_pid" == '' ] || [ ! -d /proc/$pg_pid ]; then
		rm -f /var/lock/subsys/postgresql
	fi
fi

if [ "$1" == 'restart' ]; then
	if ( su -l postgres -c "$pg_bin/pg_ctl stop -D $pg_data -s -m fast" >/dev/null 2>&1 ); then 
		rm -f "/var/lock/subsys/postgres"
	fi	
fi

if [ ! -e /var/lock/subsys/postgresql ]; then
	if ( su -l postgres -c "$pg_bin/postmaster -p $pg_port -D $pg_data &" >/dev/null 2>&1 ); then
		touch /var/lock/subsys/postgresql
    	exit 0
	else
    	exit 1
	fi
else
	exit 1
fi
