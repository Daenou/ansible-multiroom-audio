#/usr/bin/bash

ACTION=$1
IFACE=$2

LOGGER="/usr/bin/logger $0 ($ACTION $IFACE):"

# LOGGER="echo $*"

if [[ $IFACE == "lo" ]] 
then
  $LOGGER "Doing nothing"
  exit 0
fi

UPLINKUSB=""
UPSTREAMIFS="eth0 ${UPLINKUSB}"

# Expects an interface called ap0
# Expects a zone called localwlan

##################################################
# Helper functions

firewall_do () {
  $LOGGER "===== Executing: firewall-cmd $*"
  $LOGGER $( firewall-cmd $* ) 
}

serialize () {
for i in $*
do
  echo $i
done
}

##################################################
# Status

if [[ "$ACTION" == "status" ]]
then
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
    if ! serialize $( firewall-cmd --zone localwlan --list-services ) | grep -w $localservice > /dev/null 2>&1
    then
      firewall_do --zone localwlan --add-service $localservice
    fi
  done

  # Enable forwarding
  if [[ $( firewall-cmd --zone localwlan --query-forward  ) != "yes" ]]
  then
    firewall_do --zone localwlan --add-forward
  fi
fi

##################################################
# For uplink interface (if any, assume eth0 for now)

UPLINKIFACE=eth0

if [[ "$IFACE" == "$UPLINKIFACE" ]]
then
  # Bind uplink zone to uplink interface
  if [[ $( firewall-cmd --get-zone-of-interface=$IFACE ) != "uplink" ]]
  then
    firewall_do --zone uplink --add-interface=$IFACE
  fi

  # Enable local services
  for localservice in ssh
  do
    if ! serialize $( firewall-cmd --zone uplink --list-services ) | grep -w $localservice > /dev/null 2>&1
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
