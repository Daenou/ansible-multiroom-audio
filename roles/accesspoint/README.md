# accesspoint

This role configures the onboard wlan interface to act as a wifi access point. This enables the raspi to be used without internet connectivity but still use a wlan connection to control e.g. `mpd` with a mobile app.

**WARNING:** This disables the use of the onboard wlan interface to connect as client to another access point. If you are not connected to the raspi using Ethernet (or a 2nd WLAN adapter), you will lose network connectivity.

* The onboard wlan interface is renamed to `ap0`
* `ap0` is configured to have a static IPv4 and IPv6 (ULA) address
* all network interfaces are configured using NetworkManager, use `nmcli` to inspect the live configuration
* `dnsmasq` is used as DHCP-Server on `ap0` for the WLAN clients, using the NetworkManager builtin configuration does not work with the other requirements.
* the automatic network configuration built into `docker` is disabled, as it does work with the rest of the requirements (it only supports `iptables`, but not `nftables` backed `firewalld`).
* `firewalld` is used for firewalling/masquerading, use `firewall-cmd` to inspect the live configuration. The following firewalld zones are used:
  * `ap0` is in the `dmz` zone
  * `docker0` is in the `docker` zone
  * the default zone is `public`, so it applies to all interfaces except for the two above. Normally, there is only `eth0` left for this zone, but it also applies to `wlan0` (see below).

Ansible variables available are

* firewalld

  * `accesspoint_firewall_music_ports`: List of ports needed to access local services. Defaults to
    * `6600/tcp`: mpd
    * `5353/udp`: avahi  (aka zeroconf)
    * `12345/tcp`: raspotify (spotify connect)
    * `8080/tcp`: ampd
  * `accesspoint_disable_docker_networking`: Leave to true, as docker networking is not smart enough to cope with a `nftables` backed firewalld.
  * `accesspoint_trust_public_zone`: defaults to *false* (so that the services listed above are **not** visible from the upstream network). Set to **true** when you trust your uplink network.

* IPv4 (mandatory)

  * `accesspoint_ap0_address_v4`: The static IP of `ap0`, e.g. `192.168.250.1`
  * `accesspoint_ap0_prefix_v4`: The routing prefix for your IPv4 network, usually `24`
  * `accesspoint_dhcp_range_v4`: The dhcp range handed out to WLAN clients, must be part of the network defined by the address/prefix, e.g. `192.168.250.10,192.168.250.199`

* IPv6 (optional)

  * `accesspoint_ap0_v6_ula_net_48`: A `/48` [ULA](https://en.wikipedia.org/wiki/Unique_local_address) network address **without** trailing colon.
     Please do not use the same subnet as found in the example, but [generate your own](https://www.ip-six.de/index.php).
     If this variable is not defined, `ap0` won't have an IPv6 address and the following two variables are ignored.
  * `accesspoint_ap0_v6_local_64`: a 16bit (4 hex numbers), concatenated to the previous variable for the `ap0` address and the DHCPv6 range in `dnsmasq.conf`
  * `accesspoint_ap0_v6_host`: the remaining 64 bit of the IPv6 address of the `ap0` address, concatenated to the previous two variables to form the IPv6 address of the `ap0` interface.

* Layer2

  * `accesspoint_channel`: The WLAN channel to be used by the WLAN access point, eg `11`
  * `accesspoint_country_code`: country code, eg `CH`
  * `accesspoint_ssid`: Whatever SSID you want your WLAN to have, defaults to inventory hostname
  * `accesspoint_wpa_passphrase`: Whatever WPA2 passphrase you want to set, ideally to be retrieved interactively with `vars_prompt` in the playbook.

# Howto use an 2nd WLAN interface as uplink

In order to create a wifi uplink, you'll have to connect a USB-Wifi dongle that is supported by Linux first.

Next, identify the interface name the dongle received:

~~~
# nmcli dev status | grep " wifi "
ap0          wifi      connected               accesspoint
wlan0        wifi      disconnected            --
~~~

You should ensure that the new network you create does NOT attach to `ap0`, otherwise you'll lose the accesspoint and you will end up in the wrong `firewalld` zone (see above). Here, the dongle got the name `wlan0` (which is probably the case in most scenarios). Now you can first search the available networks to the `wlan0` interface:

Then look for all reachable wifi SSIDs

~~~
# nmcli dev wifi rescan ifname wlan0
# nmcli dev wifi list ifname wlan0
~~~

Check for the SSID you want to connect (and have a password for it). Connect to it with

~~~
nmcli dev wifi connect <ssid> ifname wlan0 password <password>
~~~

This will create a new NetworkManager connection that will persist reboots. If you miss the `ifname` parameter, it is possible that NetworkManager chooses the `ap0` interface. This is **not** what you want, but after a reboot the accesspoint should come up on `ap0` first due to its higher autoconnect-priority.

You can create as many connections you like, NetworkManager will select the first that works. To force a reconnection, simply disconnect the usb dongle for a few seconds.

# WLAN clients with IPv6 ULA addresses and `/etc/gai.conf`

If IPv6 is configured and you connect a client to the WLAN, it will receive an IPv6 ULA address.

Due to IPv6 masquerading, the client has full IPv6 connectivity (identical to the IPv4 connectivity
with an RFC1918 address and IPv4 masquerading).

However, the default `/etc/gai.conf` of Debian/Ubuntu
(and probably others) defines an individual *label* for ULA addresses to mark them as
*compatible with themselves only*. This makes e.g. `getent ahosts www.google.com` prefer IPv4 over
IPv6.

This can be changed by removing that safeguard from `/etc/gai.conf`. From the man page:
*If any label definition is present in the configuration file, the default table is not used. All the label definitions of the default table which are to be maintained have to be duplicated.*
Just map the ULA addresses to the same *label* as all *normal* addresses are mapped to (comments added by myself):

~~~
#loopback
label ::1/128       0
# ALL
label ::/0          1
# 6to4 (deprecated)
label 2002::/16     2
# IPv4-compatible addresses (deprecated)
label ::/96         3
# IPv4-mapped (dual stack)
label ::ffff:0:0/96 4
# Site local (obsolete)
label fec0::/10     5
# Unique local addresses
label fc00::/7      1
# Teredo
label 2001:0::/32   7
~~~

**WARNING**: if you happen to have uplink connectivity over IPv4 only, these edits can make your network experience very bad. While
browsers have "happy eyeballs" (i.e. fast fallback to IPv4), most other network applications can take up to 2 minutes to fail over
from IPv6 to IPv4.
