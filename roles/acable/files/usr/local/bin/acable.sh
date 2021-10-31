#!/bin/bash
CONFFILE="/etc/acable.conf.d/$1.conf"

# Initialize default variables
# These can be overriden in a /etc/acable.conf.d/EXAMPLE.conf file
SOURCE=$(/usr/bin/arecord -L | egrep "^dsnoop:.*$1.*$")
SINK=$(/usr/bin/aplay -L | egrep "^dmix:.*Loopback,DEV=0.*$")
FORMAT="cd"
FILETYPE="raw"
DURATION=0 # 0 equals infinite
BUFFERSIZE=8192
PERIODSIZE=1024

if [[ -f "$CONFFILE" ]];
then
	source "$CONFFILE"
fi

while true; do
	case "$1" in
		bluealsa) /usr/bin/bluealsa-aplay -vv 00:00:00:00:00:00 -d "$SINK" ;;
		*) /usr/bin/arecord -D "$SOURCE" -f "$FORMAT" -d "$DURATION" -t "$FILETYPE" --buffer-size="$BUFFERSIZE" --period-size="$PERIODSIZE" | /usr/bin/aplay -D "$SINK" -f "$FORMAT" -t "$FILETYPE" --buffer-size="$BUFFERSIZE" --period-size="$PERIODSIZE" ;;
	esac
	echo "Loop broken, restarting"
done
