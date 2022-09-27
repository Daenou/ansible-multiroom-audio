#/usr/bin/bash

ACTION=$1
IFACE=$2

LOGGER="/usr/bin/logger $0 ($ACTION $IFACE):"

# LOGGER="echo $*"

if [[ $IFACE == "lo" ]] 
then
  $LOGGER "Doing nothing for loopback interface"
  exit 0
fi

# Expects an interface called ap0
# Expects a zone called localwlan

##################################################
# Helper functions

firewall_do () {
  $LOGGER "===== Executing: firewall-cmd $*"
  $LOGGER $( firewall-cmd $* ) 
}

list2lines () {
for i in $*
do
  echo $i
done
}

##################################################
# Status

if [[ "$ACTION" != "add" ]]
then
  $LOGGER "show status"
  firewall_do --get-default-zone
  firewall_do --get-zones
  firewall_do --get-active-zones
  for zone in localwlan uplink
  do
    firewall_do --zone $zone --list-all
  done
  exit 0
fi

##################################################
# Do the real work

# Set logging of all dropped packets to /var/log/kern.log
if [[ $( firewall-cmd --get-log-denied ) != "all" ]]
then
  firewall_do --set-log-denied all
fi

$LOGGER "Working on $IFACE"

##################################################
# For ap0

if [[ "$IFACE" == "ap0" ]]
then
  # Bind localwlan zone to ap0 interface
  if [[ $( firewall-cmd --get-zone-of-interface=ap0 ) != "localwlan" ]]
  then
    firewall_do --zone localwlan --add-interface=ap0
  fi

  # Enable local services
  for localservice in dhcp dns ssh
  do
    if ! list2lines $( firewall-cmd --zone localwlan --list-services ) | grep -w $localservice > /dev/null 2>&1
    then
      firewall_do --zone localwlan --add-service $localservice
    fi
  done

  # Enable local tcp ports
  # 6600: MPD control port
  for port in 6600
  do
    if ! list2lines $( firewall-cmd --zone localwlan --list-ports ) | grep -w $port > /dev/null 2>&1
    then
      firewall_do --zone localwlan --add-port=$port/tcp
    fi
  done

  # Enable forwarding
  if [[ $( firewall-cmd --zone localwlan --query-forward  ) != "yes" ]]
  then
    firewall_do --zone localwlan --add-forward
  fi
else
  # all other interfaces are considered to be uplink interfaces
  #
  # for information only: check if this is the interface having the most attractive default route right now
  # need to apply rules even when this interface is not the default route right now, it is
  # possible that this changes later 

  ACTIVEUPLINK=$( ip route get 1.1.1.1 | sed -ne "s/^.* dev \([^ ]*\) .*$/\1/p" )

  if [[ -n "$ACTIVEUPLINK" ]]
  then
    if [[ "$ACTIVEUPLINK" == "$IFACE" ]]
    then
      $LOGGER "$IFACE is the currently active uplink"
    else
      $LOGGER "$IFACE is different from the currently active uplink $ACTIVEUPLINK"
    fi
  else
    $LOGGER "no interface to reach 1.1.1.1, offline?"
  fi

  # Bind uplink zone to uplink interface
  if [[ $( firewall-cmd --get-zone-of-interface=$IFACE ) != "uplink" ]]
  then
    firewall_do --zone uplink --add-interface=$IFACE
  fi

  # Enable local services
  for localservice in ssh
  do
    if ! list2lines $( firewall-cmd --zone uplink --list-services ) | grep -w $localservice > /dev/null 2>&1
    then
      firewall_do --zone uplink --add-service $localservice
    fi
  done

  # Enable masquerading on uplink
  if [[ $( firewall-cmd --zone uplink --query-masquerade ) != "yes" ]]
  then
    firewall_do --zone uplink --add-masquerade
  fi
fi