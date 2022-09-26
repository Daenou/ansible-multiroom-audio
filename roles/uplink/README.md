# uplink

Provided that you already use the `accesspoint` role to convert your pi to a WLAN access point, this role takes you one step further: As all interfaces except `ap0` are still under the control of `dhcpcd`, they will eventually receive an uplink configuration via DHCP. This can be the built in ethernet interface or an additional usb network dongle (ethernet/WLAN/5G/...). 

This role configures (IPv4) routing, masquerading and filtering to allow any device on the `ap0` WLAN to reuse the uplink discovered by `dhcpcd`.

Firewall concept in a nutshell:

* `firewalld`
* `FORWARD`: All incoming traffic is denied, except
  * the connection was initiated via `ap0` (i.e. WLAN clients)
  * it is ICMP traffic
  * it is ssh traffic
* `INPUT`: Special ruleset for local services 
* `OUTPUT`: open

The firewall is implemented using a bash script around `firewall-cmd`. This is not the nicest way of doing things, but I wanted to preserve the ability to completely recreate the firewall rules independent from ansible or previously saved state (that could contain manual changes).
