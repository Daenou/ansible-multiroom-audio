# accesspoint

This role configures the onboard wlan interface to act as access point. This enables the raspi to be used without internet connectivity but still use a wlan connection to control e.g. `mpd` with a mobile app.

**WARNING:** This disables the use of the onboard wlan interface to connect as client to another access point. If you are not connected to the raspi using Ethernet (or a 2nd WLAN adapter), you will lose network connectivity.

* The onboard wlan interface is renamed to `ap0`
* `ap0` is configured to have a static IPv4 address
* `dhcpcd` is configured to release control of `ap0` to free it up for `hostapd` and `ifup`/`ifdown` management. All other network interfaces remain under control of `dhcpcd`
* `hostapd` is used to create a WPA2 hotspot on `ap0`
* `dnsmasq` is used as DHCP-Server on `ap0` for the WLAN clients

Ansible variables available are

* IPv4 (mandatory)

  * `accesspoint_ap0_address_v4`: The static IP of `ap0`, e.g. `192.168.250.1`
  * `accesspoint_ap0_mask_v4`: The network mask, e.g. `255.255.255.0`
  * `accesspoint_dhcp_range_v4`: The dhcp range handed out to WLAN clients, must be part of the network defined by the address/mask, e.g. `192.168.250.10,192.168.250.199`

* IPv6 (optional)

  * `accesspoint_ap0_v6_ula_net_48`: A `/48` [ULA](https://en.wikipedia.org/wiki/Unique_local_address) network address.
     Please do not use the same subnet as found in the example, but [generate your own](https://www.ip-six.de/index.php).
     If this variable is not defined, `ap0` won't have an IPv6 address and the following two variables are ignored.
  * `accesspoint_ap0_v6_local_64`: a 16bit (4 hex numbers), concatenated to the previous variable for the `ap0` address and the DHCPv6 range in `dnsmasq.conf`
  * `accesspoint_ap0_v6_host`: the remaining 64 bit of the IPv6 address of the `ap0` address

* Layer2

  * `accesspoint_channel`: The WLAN channel to be used by the WLAN access point, eg `11`
  * `accesspoint_ieee80211d`: Enable transmission of additional network information, needs correct country code, `0` or `1`
  * `accesspoint_country_code`: country code, eg `CH`
  * `accesspoint_ssid`: Whatever SSID you want your WLAN to have, defaults to inventory hostname
  * `accesspoint_wpa_passphrase`: Whatever WPA2 passphrase you want to set, ideally to be retrieved interactively with `vars_prompt` in the playbook.

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
Just map the ULA addresses to the same *label* as all *normal* addresses are mapped to (comments added by mysel):

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
