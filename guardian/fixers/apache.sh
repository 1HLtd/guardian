#!/bin/bash

VERSION='0.0.2'

# Check if we have enough semaphores to start Apache
critical=10

let threshold=$(awk '{print $4}' /proc/sys/kernel/sem )-$critical
# skip the header and blank lines
let current=$(ipcs -s |wc -l)-4

if [ "$current" -gt "$threshold" ]; then
	abuser=$(ipcs -s |awk '{print $3}' |sort |uniq -c |sort -b -n |tail -n 1|awk '{print $2}')
	echo "$(date '+%b %d %T') Info: too many semaphores($current), cleanup trigged by httpd fixer script" >> /var/log/1h/guardian.log
	for i in $(ipcs -s |awk "/$abuser/{print \$2}"); do
		ipcrm -s $i
	done
fi

# Check if SSL mutex file exists (if the file exists it may prevent Apache from starting normally)
apache_conf='/usr/local/apache/conf/httpd.conf'
ssl_mutex=''

if [ -f "$apache_conf" ]; then
	ssl_mutex=$(awk -F: '/^[[:space:]]*(SSL)?Mutex[[:space:]]+file:/ {print $2}' "$apache_conf")

	if [ -f "$ssl_mutex" ]; then
		echo "$(date '+%b %d %T') Info: SSL mutex file found ($ssl_mutex), cleanup trigged by httpd fixer script" >> /var/log/1h/guardian.log
		unlink "$ssl_mutex"
	fi
fi
