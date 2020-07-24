#!/bin/bash

for ftp_daemon in pure-ftpd pure-authd proftpd; do
	pkill -f $ftp_daemon 2>/dev/null
done

exit 0
