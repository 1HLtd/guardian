#!/bin/bash
# 1H - Setup guardian init scripts
#
# This code is covered by GPLv2 license

VERSION='0.1.0'

if [ -x /etc/init.d/proftpd ]; then
	if ( ! ln -sf /etc/init.d/proftpd /usr/local/1h/lib/guardian/init/ftp.sh ); then
		exit 1
	fi
fi

if [ -x /etc/init.d/mysqld ]; then
	if ( ! ln -sf /etc/init.d/mysqld /usr/local/1h/lib/guardian/init/mysql.sh ); then
		exit 1
	fi
fi

# This is a DA server
if [ -x /etc/init.d/directadmin ]; then
	if [ -x /etc/init.d/dovecot ] && [ -x /usr/local/1h/lib/guardian/init/dovecot.sh ] && ( ! grep sleep /usr/local/1h/lib/guardian/init/dovecot.sh ); then
		if ( ! echo 'sleep 2' >> /usr/local/1h/lib/guardian/init/dovecot.sh ); then
			exit 1
		fi
	fi
	if [ -f /etc/init.d/exim ]; then
		# Remove the -a option from /etc/init.d/exim. It is not recognized by spamd
		if ( ! sed -i '/spamd -d -a -c/s/-a //' /etc/init.d/exim ); then
			exit 1
		fi
	fi
	cd /sbin
	patch -p0 < /usr/local/1h/lib/guardian/service.patch
fi

# This is a Plesk server
if [ -x /etc/init.d/psa ]; then
	# On plesk servers it is common the named to be started from a chrooted enviroment
	# - In that case we should modify our init script for named according to the configuration found in /etc/sysconfig/named
	named_init='/usr/local/1h/lib/guardian/init/named.sh'
	if [ ! -f /etc/sysconfig/named ]; then
		exit 0
	fi
	. /etc/sysconfig/named
	append=''
	if [ ! -z "$OPTIONS" ]; then
		OPTIONS_TMP=$(echo $OPTIONS | sed 's/-/\\-/g')
		if ( ! grep "$OPTIONS_TMP" $named_init ); then
			append="$OPTIONS"
		fi
	fi
	if [ ! -z "$ROOTDIR" ]; then
		if ( ! grep "$ROOTDIR" $named_init ); then
			append="$append -t $ROOTDIR"
		fi
	fi
	if [ ! -z "$append" ]; then
		echo "Append is: $append"
		append=$(echo "$append" | sed 's/\//\\\//g')
		sed -i "/named -u named/s/>\/dev\/null/$append >\/dev\/null/" $named_init
	fi
fi

exit 0
