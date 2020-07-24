#!/bin/bash

########################################################
#
#  Guardian init script for start/restart of courier imap/pop3/authd
#
########################################################

# return codes
# 0 - success
# 1 - unable to start

pidfiles='/var/run/pop3d.pid /var/run/pop3d-ssl.pid /var/run/imapd.pid /var/run/imapd-ssl.pid /var/spool/authdaemon/pid'
UMASK=022
VIRTMEMLIMIT=65536
# Set the umask
# Fix the ulimits
# Start pop3
# Start imap
# Start imap-ssl
# Start pop3-ssl
# No other tests so far :)
DEAMONCMDS="umask $UMASK
ulimit -v $VIRTMEMLIMIT
/usr/sbin/courierlogger -pid=/var/run/pop3d.pid -start -name=pop3d /usr/lib/courier-imap/libexec/couriertcpd -address=0 -maxprocs=50 -maxperip=30 -nodnslookup -noidentlookup 110 /usr/lib/courier-imap/sbin/pop3login /usr/lib/courier-imap/bin/pop3d Maildir
/usr/sbin/courierlogger -pid=/var/run/imapd.pid -start -name=imapd /usr/lib/courier-imap/libexec/couriertcpd -address=0 -maxprocs=50 -maxperip=30 -nodnslookup -noidentlookup 143 /usr/lib/courier-imap/sbin/imaplogin /usr/lib/courier-imap/bin/imapd Maildir
/usr/sbin/courierlogger -pid=/var/run/imapd-ssl.pid -start -name=imapd-ssl /usr/lib/courier-imap/libexec/couriertcpd -address=0 -maxprocs=50 -maxperip=30 -nodnslookup -noidentlookup 993 /usr/lib/courier-imap/bin/couriertls -server -tcpd /usr/lib/courier-imap/sbin/imaplogin /usr/lib/courier-imap/bin/imapd Maildir
/usr/sbin/courierlogger -pid=/var/run/pop3d-ssl.pid -start -name=pop3d-ssl /usr/lib/courier-imap/libexec/couriertcpd -address=0 -maxprocs=50 -maxperip=30 -nodnslookup -noidentlookup 995 /usr/lib/courier-imap/bin/couriertls -server -tcpd /usr/lib/courier-imap/sbin/pop3login /usr/lib/courier-imap/bin/pop3d Maildir
/usr/sbin/courierlogger -pid=/var/spool/authdaemon/pid -facility=mail -start /usr/libexec/courier-authlib/authdaemond"

if [ "$1" == 'restart' ]; then
	for pidfile in $pidfiles; do
		if [ -f $pidfile ] && [ -d /proc/$(<$pidfile) ]; then
			/bin/kill -9 $(<$pidfile) > /dev/null 2>&1
		fi
	done
	killall -9 couriertcpd
	killall -9 authdaemond
	killall -9 pop3login
fi

echo "$DEAMONCMDS" | while read cmd; do
	#echo "Running $cmd"
	if ( ! $cmd ); then
		#echo "$cmd failed"
		exit 1
	fi
done

for pidfile in $pidfiles; do
	if [ ! -f $pidfile ] || [ ! -d /proc/$(<$pidfile) ]; then
		echo "Wrong pidsss"
		exit 1
	fi
done

exit 0
