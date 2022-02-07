#!/bin/bash
CONFFILE="/etc/acable.conf.d/$1.conf"

# Initialize default variables
# These can be overriden in a /etc/acable.conf.d/EXAMPLE.conf file
SOURCE=$(/usr/bin/arecord -L | egrep "^dsnoop:.*$1.*$")
SINK=$(/usr/bin/aplay -L | egrep "^dmix:.*Loopback,DEV=0.*$")
FORMAT="cd"
FILETYPE="raw"
DURATION=0 # 0 equals infinite

if [[ -f "$CONFFILE" ]];
then
	source "$CONFFILE"
fi

if [[ -z "${BUFFERSIZE}" ]] ; then
  BUFFERSIZEPARAM=""
else
  BUFFERSIZEPARAM="--buffer-size=${BUFFERSIZE}"
fi

if [[ -z "${PERIODSIZE}" ]] ; then
  PERIODSIZEPARAM=""
else
  PERIODSIZEPARAM="--period-size=${PERIODSIZE}"
fi

wait_for_and_get_first_connected_source() {
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
echo "bluealsa:SRV=org.bluealsa,DEV=${MAC},PROFILE=a2dp"
}


alloutputs(){

action=$1

# todo: in addition, stop/start other acables/components writing to dmix of soundcard, but not ourselves!
allsnapclients=$( systemctl -a | grep snapclient@ | awk ' { print $1 } ' )

doforall(){
for i in $allsnapclients; do
  echo "executing $1 $i"
  $1 $i
done
}

case "$action" in
  stop ) doforall "systemctl stop" ;;
  start) doforall "systemctl start" ;;
  *    ) doforall "echo" ;;
esac

}

arecaplaypipe() {
        SR="$1"
        echo "Using source $SR"
        alloutputs stop
	/usr/bin/arecord -D "$SR" -f "$FORMAT" -d "$DURATION" -t "$FILETYPE" ${BUFFERSIZEPARAM} ${PERIODSIZEPARAM} |\
	/usr/bin/aplay -D "$SINK" -f "$FORMAT" -d "$DURATION" -t "$FILETYPE" ${BUFFERSIZEPARAM} ${PERIODSIZEPARAM} &
        alloutputs start
        wait
}

while true; do
        case "$1" in
	        bluealsa-cable) /usr/bin/bluealsa-aplay -vv 00:00:00:00:00:00 -d "$SINK" 
                        ;;
		bluealsa-workaround-cable) 
                        echo "Waiting for bt device to connect"
			arecaplaypipe $( wait_for_and_get_first_connected_source )
			;;
		*) arecaplaypipe "$SOURCE"
                        ;;
	esac
	echo "Loop broken, restarting"
        sleep 1
done
