#!/bin/bash
DEVNAME=$1
while true; do
	case "$DEVNAME" in
		bluealsa) /usr/bin/bluealsa-aplay -vv 00:00:00:00:00:00 -d dmix:CARD=Loopback,DEV=0 ;;
		*) /usr/bin/arecord -f cd -D $(/usr/bin/arecord -L | egrep "^dsnoop:.*$DEVNAME.*$") -f cd -d 0 -t raw | /usr/bin/aplay -f cd -D dmix:CARD=Loopback,DEV=0 -t raw ;;
	esac
	echo "Loop broken, restarting"
done
