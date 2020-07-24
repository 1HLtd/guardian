#!/bin/bash
# 1H - Guardian setup
#
# This code is covered by GPLv2 license

VERSION='0.3.0'

. /usr/local/1h/bin/guardian_check_services.sh
portal_ip=''

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
protected_users='root mysql nscd named mailnull postgres cpanel qmails qmaill qmailr qmailq mail'
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

exit 0
