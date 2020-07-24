#!/bin/bash

VERSION='0.0.5'
local_dir='/usr/local/1h'
dst_cron="/var/spool/cron/crontabs/root"

if [ -f "/root/.pgpass" ]; then
	portal_pass=$(awk -F : '$4 ~ /^portal$/{print $5}' /root/.pgpass)
fi

if [ -z "$portal_pass" ]; then
	echo "Portal pass is empty. Not fatal - continuing."
else
	if ( ! sed -i "/^pgpass/s/=.*/=$portal_pass/" $local_dir/etc/archon.conf ); then
		echo "Failed to add fix the db pass for portal in $local_dir/etc/archon.conf"
		exit 1
	fi
fi

if ( ! grep archon-hb-cron.sh "${dst_cron}" ); then
	if ( ! chattr -ia ${dst_cron} ); then
		echo "[!] chattr -ia ${dst_cron} FAILED"
		exit 1
	fi
	if ( ! echo '*/1 * * * * /usr/local/1h/sbin/archon-hb-cron.sh >> /usr/local/1h/var/log/archon.log 2>&1' >> ${dst_cron} ); then
		echo "[!] Failed to add archon-hb-cron.sh script to the root's cron"
		exit 1
	fi
fi

if [ -d /usr/local/1h/lib/guardian/svcstop ]; then
	touch /usr/local/1h/lib/guardian/svcstop/crond
fi

if ( ! /etc/init.d/cron restart ); then
	echo "/etc/init.d/cron restart failed"
	exit 1
fi
rm -f /usr/local/1h/lib/guardian/svcstop/cron

if ( chkconfig --list | awk "/3:on/{print \$1}" | grep ^csf$ ); then
	if [ -f /etc/csf/csf.conf ]; then
		if ( ! sed -i '/TCP_OUT/s/"$/,1022"/' /etc/csf/csf.conf ); then
			echo "failed to add 1022 in TCP_OUT at /etc/csf/csf.conf"
			exit 1
		fi
	fi
	if [ -x /etc/init.d/csf ]; then
		if ( ! /etc/init.d/csf restart ); then
			echo "failed to restart csf"
			exit 1
		fi
	fi
fi

if ( chkconfig --list | awk "/3:on/{print \$1}"  | grep -i ^ip.*tables$ ) && [ -f /etc/sysconfig/iptables ]; then
	rule="-I OUTPUT -p tcp --dport 1022 -j ACCEPT"
	if ( ! sed -i "/^:OUTPUT/a$rule" /etc/sysconfig/iptables ); then
		echo "failed to add $rule to /etc/sysconfig/iptables"
		exit 1
	fi
	if ( ! iptables $rule ); then
		echo "iptables $rule failed"
		exit 1
	fi
fi

if ( ! chkconfig --add archon ); then
	echo "[!] chkconfig --add archon FAILED"
	exit 1
fi
if ( ! chkconfig archon on ); then
	echo "[!] chkconfig archon on FAILED"
	exit 1
fi

# Exit cleanly at the end
exit 0
