#!/bin/bash

VERSION='0.0.1'

for i in 1 2 3 4 5; do
        /usr/local/1h/sbin/archon-hb.pl > /usr/local/1h/var/log/archon-hb.log 2>&1
        sleep 9
done
