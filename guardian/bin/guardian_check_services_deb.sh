#!/bin/bash
# 1H - Guardian check services
#
# This code is covered by GPLv2 license

VERSION='0.1.6'

function configure_guardian() {
	services=''
	scount=0
	# This code is not used?
	for i in $(chkconfig --list|awk '/3:on/{print $1}'); do
		service=''
		if [ "$i" == 'httpd' ] || [ "$i" == 'apache' ] || [ "$i" == 'apache2' ]; then	 
			# Check if this looks like litespeed httpd setup known from cPanel
			if [ -f /usr/local/apache/bin/httpd ] && ( file /usr/local/apache/bin/httpd | grep 'Bourne shell' >> /dev/null ) && [ -d /usr/local/lsws ]; then
				service=litespeed
			else
				service=apache
			fi
		fi
		if [ "$i" == 'lsws' ]; then
			service=litespeed
		fi
		if [ "$i" == 'directadmin' ]; then
			service=directadmin
		fi
		if [ "$i" == 'nginx' ]; then
			service=nginx
		fi
		if [ "$i" == 'proftpd' ] || [ "$i" == 'pure-ftpd' ]; then
			service=ftp
		fi
		if [ "$i" == 'mysql' ] || [ "$i" == "mysqld" ]; then
			service=mysql
		fi
		if [ "$i" == 'crond' ] || [ "$i" == "cron" ]; then
			service=crond
		fi
		if [ "$i" == 'dovecot' ]; then
			service=dovecot
		fi
		if [ "$i" == 'courier-imap' ]; then
			if ( ! ps uaxwf | grep -v grep | grep -i courier >> /dev/null 2>&1 ); then
				continue
			fi
			service=courier
		fi
		if [ "$i" == 'named' ] || [ "$i" == 'bind9' ] || [ "$i" == 'bind' ]; then
			service=named
		fi
		if [ "$i" == 'postgresql' ]; then
			service=postgres
		fi
		if [ "$i" == 'nscd' ]; then
			service=nscd
		fi
		if [ "$i" == 'hawk' ]; then
			service=hawk
		fi
		if [ "$i" == 'multistatsd' ]; then
			service=multistatsd
		fi
		if [ "$i" == 'cpanel' ]; then
			service='cpanel,cpanellogd'
		fi
		if [ "$i" == 'exim' ] || [ "$i" == 'exim4' ] || [ "$i" == 'exim3' ]; then
			service=exim
		fi
		if [ "$i" == 'qmail' ]; then
			service=qmail
		fi
		if [ "$i" == 'psa' ]; then
			service=plesk
		fi
		if [ -z "$service" ]; then
			# $service is empty so we go ahead
			continue
		fi
		if [ "$scount" == 0 ]; then
			services="$service"
		else
			services="$services,$service"
		fi
		let scount++
	done
	if [ -x '/etc/init.d/psa' ]; then
		additional_checks='httpd named'
		for additional_check in $additional_checks; do
			# If additional_check is not found in the services list but it is executable in /etc/init.d/ we add it as well
			if [[ "$services" =~ $additional_check ]]; then
				# $additional_check is already found in $services
				continue
			fi
			if [ ! -x /etc/init.d/$additional_check ]; then
				# $additional_check is not found as executable in /etc/init.d/$additional_check
				continue
			fi
			# If we are here this means that we should consider $additional_check as active service that should be added to $services
			if [ "$scount" == 0 ]; then
				services="$additional_check"
			else
				services="$services,$additional_check"
			fi
			let scount++
		done
	fi
	echo "$services,lifesigns"
	return $scount
}

if [ $# -gt 0 ]; then
	configure_guardian
fi
