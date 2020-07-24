#!/bin/bash
# This code is covered by GPLv2 license

services='httpd$|mysqld$|proftpd$|postgresql$|named$|exim$|crond$|dovecot$|nscd$'

function is_monitored {
	if ( echo $1 | grep -E $services > /dev/null ); then
		return 0; 
	fi 
	return 1; 
}

function restart_monitor {
	svc=$1
	case "$1" in 
		httpd)		svc=apache ;; 
		mysqld)		svc=mysql ;; 
		proftpd)	svc=ftp ;; 
		postgresql)	svs=postgres ;; 
	esac
	if [ -d /usr/local/1h/lib/guardian/services ]; then
    	touch /usr/local/1h/lib/guardian/services/$svc
	fi
    return 0
}
