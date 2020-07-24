#!/bin/bash
########################################################
#
#  Guardian init script for start/restart of Exim
#
########################################################

# return codes
# 0 - success
# 1 - unable to start
# 2 - wrong configuration
# 3 - configuration file missing

QUEUE='15m'
ALTPORT='2525'
TLS=true
OUTGOING=false

pidfile='/var/run/exim.pid'
pidfile_ssl='/var/run/exim_ssl.pid'
pidfile_alt='/var/run/exim_alt.pid'
pidfile_spamd='/var/run/spamd.pid'
version='0.4'

if [ ! -f /usr/sbin/exim ] || [ ! -f /etc/exim.conf ]; then
	exit 3
fi

killall -9 exim spamd

if ( ! /usr/sbin/exim -bd -q "$QUEUE" -oP "$pidfile" ); then
	exit 1
fi
if $OUTGOING; then
	if [ ! -f /etc/exim_outgoing.conf ]; then
		exit 3
	fi
	if ( ! /usr/sbin/exim -C /etc/exim_outgoing.conf -q "$QUEUE" ); then
		exit 1
	fi
fi
if $TLS; then
	if ( ! /usr/sbin/exim -tls-on-connect -bd -oX 465 -oP "$pidfile_ssl" ); then
		exit 1
	fi
fi
if [ "$ALTPORT" -ne 0 ]; then
	if ( ! /usr/sbin/exim -bd -oX "$ALTPORT" -oP "$pidfile_alt" ); then
		exit 1
	fi
fi

for spamd in /usr/local/cpanel/3rdparty/perl/514/bin/spamd /usr/local/bin/spamd /usr/bin/spamd; do
	if [ ! -x "${spamd}" ]; then
		continue
	fi
	if ( ! ${spamd} -d --socketpath=/var/run/spamd.sock --pidfile="$pidfile_spamd" --max-children=5 ); then
		exit 1
	fi
	# Launch the first found and exit the loop
	break
done

exit 0
