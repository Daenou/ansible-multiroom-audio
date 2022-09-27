# uplink

Provided that you already use the `accesspoint` role to convert your pi to a WLAN access point, this role takes you one step further: As all interfaces except `ap0` are still under the control of `dhcpcd`, they will eventually receive an uplink configuration via DHCP. This can be the built in ethernet interface or an additional usb network dongle (ethernet/WLAN/5G/...). 

This role configures (IPv4) routing, masquerading and filtering to allow any device on the `ap0` WLAN to reuse the uplink discovered by `dhcpcd`.
Firewall concept in a nutshell:

* `firewalld`, two zones
  * **localwlan**: This is where the clients connected to the access point are
  * **uplink**: This is where the uplink connection goes to
* Implementation in a shell script with lots of `firewall-cmd` commands that is triggered by udev when interface comes up
  * This enables mapping the uplink zone to an interface that was not present at boot (e.g. USB dongle).
  * This enables reconfiguring the firewall at any time
* No permanent changes to the rules except where this cannot be done otherwise:
  * Enabling logging of all dropped packages
  * New zones
* All traffic from `localwlan` is allowed and masqueraded before being sent out on `uplink`.
* **WARNING** This is my first `firewalld` configuration, I am sure I could tighten it up even more.
