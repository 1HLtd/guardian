#!/bin/bash
# 1H - Guardian setup                               Copyright(c) 2010 1H Ltd.
#                                                        All rights Reserved.
# copyright@1h.com                                              http://1h.com
# This code is subject to the 1H license. Unauthorized copying is prohibited.

VERSION='0.2.3'

. /usr/local/1h/bin/guardian_check_services.sh
portal_ip=

# Setup the init scripts
for service in guardian lifesigns; do
	echo "Adding service $service to the chkconfig"
	if chkconfig --list|grep $service > /dev/null; then
		fix_levels=0
		chkconfig --list|grep $service|while read a b c lvl2 lvl3 lvl4 lvl5 h ; do 
			for i in $lvl2 $lvl3 $lvl4 $lvl5; do
				if echo "$i"|grep off > /dev/null; then
					fix_levels=1
				fi
			done
		done
		if [ "$fix_levels" -eq 1 ]; then
			chkconfig --level 2345 $service on
		fi
	else
		chkconfig --add $service
		chkconfig --level 2345 $service on
	fi
done

# Setup guardian links
if [ ! -h /svc ]; then
	ln -s /usr/local/1h/lib/guardian/services /svc
fi
if [ ! -h /svcstop ]; then
	ln -s /usr/local/1h/lib/guardian/svcstop /svcstop
fi
if [ ! -h /var/log/1h ]; then
	ln -s /usr/local/1h/var/log /var/log/1h
fi
if [ ! -h /etc/guardian.conf ]; then
	ln -sf /usr/local/1h/etc/guardian.conf /etc/guardian.conf
fi

# Detect running services
services=$(configure_guardian)
if [ ! -z "$services" ]; then
	sed -i "/check_services/s/=.*/=$services/" /usr/local/1h/etc/guardian.conf
fi

# Detect existing users that we should protect
protected_users='root mysql nscd named mailnull postgres cpanel qmails qmaill qmailr qmailq'
protected_list=''
for protected_user in $protected_users; do
	if ( ! grep "^$protected_user:" /etc/passwd >> /dev/null 2>&1 ); then
		continue
	fi
	protected_list="$protected_list,$protected_user"
done
# Strip the leading ,
protected_list=$(echo "$protected_list" | sed 's/^,//g')
if [ ! -z "$protected_list" ]; then
	#echo "$protected_list"
	sed -i "/protected_users/s/=.*/=$protected_list/" /usr/local/1h/etc/guardian.conf
fi
 
# Set the portal_ip for lifesigns
#  If portal_ip is not defined, we simply disallow all connections
echo "Got IP for lifesigns.conf $portal_ip"
sed -i "/allow_from/s/=.*/=$portal_ip/" /usr/local/1h/etc/lifesigns.conf
sed -i '/allow_root/s/=.*/=/' /usr/local/1h/etc/lifesigns.conf

if [ -x /usr/local/cpanel/libexec/tailwatchd ]; then
	# Make sure to turn off chksrvd prior starting guardian if this is a cPanel server
	touch /etc/chkservddisable
	/usr/local/cpanel/libexec/tailwatchd --disable=Cpanel::TailWatch::ChkServd
	/usr/local/cpanel/libexec/tailwatchd --stop
	/usr/local/cpanel/libexec/tailwatchd --start
elif [ -f /usr/local/directadmin/data/admin/services.status ]; then
	# If this is a direct admin server make sure to turn off the monitoring of the services 
	stop_monitoring='directadmin dovecot exim httpd mysqld named proftpd'
	for stop_monitor in $stop_monitoring; do
		sed -i "/^$stop_monitor/s/=.*/=OFF/" /usr/local/directadmin/data/admin/services.status
	done
fi

if ( ! /usr/bin/perl -MDBD::mysql -e 1 2>/dev/null ); then
	echo "Guardian DBD::mysql module is not operational during installation. Reinstalling it"

	if ( ! yes | /usr/bin/perl -MCPAN -e "CPAN::Shell->force(qw(install DBD::mysql))" 2>/dev/null ); then
		echo "yes | /usr/bin/perl -MCPAN -e 'install DBD::mysql' failed"
		exit 1
	fi
	if ( ! /usr/bin/perl -MDBD::mysql -e 1 2>/dev/null ); then
		echo "Even we reinstalled DBD::mysql for guardian this module still does not work. Exiting now."
		exit 1
	fi
else
	echo "DBD::mysql for guardian is operational"
fi

exit 0
