#!/bin/bash
########################################################
#
#  Guardian init script for start/restart of Cron Daemon
#
########################################################

# return codes
# 0 - success
# 1 - unable to start
# 2 - wrong configuration
# 3 - configuration file missing
# 4 - cron daemon bin not found

version='0.0.3'
cron_bins='/usr/sbin/crond /usr/sbin/cron'
cron_bin=''

# Find which is the valid cron daemon binary on this machine
for bin in ${cron_bins}; do
	if [ ! -x "${bin}" ]; then
		continue
	fi
	cron_bin="${bin}"
done
#echo "Cron bin: ${cron_bin}"
if [ -z "${cron_bin}" ]; then
	exit 4
fi

# Get bin basename for killing
cron_base=$(basename ${cron_bin})

#echo "Cron basename: ${cron_base}"
# Kill any remaining
killall -9 "${cron_base}" 2> /dev/null

if ( ! "${cron_bin}" ); then
	exit 1
fi

exit 0
