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
  $LOGGER $( firewall-cmd $* 2>&1 )
}

# Rich rules contain spaces, simple approach above does not work any more
firewall_do_richrule () {
  zone="$1"
  shift
  rule="$*"
  $LOGGER "===== Executing: firewall-cmd --zone $zone --add-rich-rule \"$rule\""
  $LOGGER $( firewall-cmd --zone $zone --add-rich-rule "$rule" 2>&1 )
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
  for localservice in dhcp dhcpv6 dns mdns ssh
  do
    if ! list2lines $( firewall-cmd --zone localwlan --list-services ) | grep -w $localservice > /dev/null 2>&1
    then
      firewall_do --zone localwlan --add-service $localservice
    fi
  done

  # Enable local tcp/udp ports
  for port in {{ uplink_localwlan_ports | join (' ') }}
  do
    if ! list2lines $( firewall-cmd --zone localwlan --list-ports ) | grep -w $port > /dev/null 2>&1
    then
      firewall_do --zone localwlan --add-port=$port
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
  for localservice in ssh dhcpv6-client
  do
    if ! list2lines $( firewall-cmd --zone uplink --list-services ) | grep -w $localservice > /dev/null 2>&1
    then
      firewall_do --zone uplink --add-service $localservice
    fi
  done

  # Enable ping to ease debugging

  if [[ $( firewall-cmd --zone uplink --query-icmp-block-inversion ) != "yes" ]]
  then
    firewall_do --zone uplink --add-icmp-block-inversion
  fi

  if ! list2lines $( firewall-cmd --zone uplink --list-icmp-block) | grep -w echo-request > /dev/null 2>&1
  then
    firewall_do --zone uplink --add-icmp-block echo-request
  fi

  # Enable IPv4 masquerading on uplink
  if [[ $( firewall-cmd --zone uplink --query-masquerade ) != "yes" ]]
  then
    firewall_do --zone uplink --add-masquerade
  fi

  # Enable IPv6 masquerading on uplink
  IPV6MASQ_RICHRULE='rule family="ipv6" masquerade'
  if [[ $( firewall-cmd --zone uplink --query-rich-rule "${IPV6MASQ_RICHRULE}" ) != "yes" ]]
  then
    firewall_do_richrule uplink "${IPV6MASQ_RICHRULE}"
  fi

fi

$LOGGER "done."
