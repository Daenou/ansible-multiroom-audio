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

wait_for_and_get_first_connected_mac () {
MAC="NULL"
while [[ "$MAC" == "NULL" ]]; do
        for tryMAC in  $( bluetoothctl devices | sort -k 3 | awk ' { print $2 } ' ) 
        do
                if [[ $( bluetoothctl info ${tryMAC} | grep Connected | awk ' { print $2 } ' ) == "yes" ]]; then
                        MAC=$tryMAC
                        break
                fi
        done
        if [[ "$MAC" == "NULL" ]]; then
                sleep 1
        fi
done
echo "$MAC"
}

while true; do
        case "$1" in
	        bluealsa) /usr/bin/bluealsa-aplay -vv 00:00:00:00:00:00 -d "$SINK" 
                        ;;
                *)      if [[ "$1" == bluediscover ]]; then
                                echo "Waiting for bt device to connect"
                                MAC=$( wait_for_and_get_first_connected_mac ) 
                                SOURCE="bluealsa:SRV=org.bluealsa,DEV=${MAC},PROFILE=a2dp"
                                echo "Using discovered SOURCE $SOURCE"
                        fi
                        /usr/bin/arecord -D "$SOURCE" -f "$FORMAT" -d "$DURATION" -t "$FILETYPE" --buffer-size="$BUFFERSIZE" --period-size="$PERIODSIZE" | \
                          /usr/bin/aplay -D "$SINK"   -f "$FORMAT" -d "$DURATION" -t "$FILETYPE" --buffer-size="$BUFFERSIZE" --period-size="$PERIODSIZE" 
                        ;;
	esac
	echo "Loop broken, restarting"
        sleep 1
done
