# uplink

Provided that you already use the `accesspoint` role to convert your pi into a WLAN access point, this role takes you one step further: As all interfaces except `ap0` are still under the control of `dhcpcd`, they will eventually receive an uplink configuration via DHCP. This can be the built in ethernet interface or an additional usb network dongle (ethernet/WLAN/5G/...). 

This role configures IPv4 routing, masquerading and filtering to allow any device on the `ap0` WLAN to reuse the uplink discovered by `dhcpcd`.
Firewall concept in a nutshell:

* `firewalld`, two zones
  * **localwlan**: wireless clients connected to the `ap0` access point
  * **uplink**: connection(s) to the internet
  * All traffic from `localwlan` is allowed and masqueraded before being sent out on `uplink`.
* Implementation in `/usr/local/bin/uplink-filter.sh` with some `firewall-cmd` commands. It is triggered by `udev` for each interface that comes up.
* All dropped packets are logged to `/var/log/kern.log`. Eases firewall debugging massively and default logrotate config has proven to be efficient enough, never had an issue.
* Action depending on interface name
    * `lo`: Nothing else happens
    * `ap0`: if not done before, `ap0` is mapped to zone `localwlan`, zone is configured
    * all other interface names (including `eth0`): if not done before, interface mapped to zone `uplink`, zone is configured (incoming `ssh` only). 
* Changes are not made persistent except where persistency is the only `firewalld` option: packet logging and the two zones. Persistency from `firewalld` is not needed, as the settings are applied (if not there already) whenever an interface comes up.
* **WARNING**: This is my first `firewalld` configuration, I am sure I could tighten it up even more.

## Hints for bootstrapping a WLAN uplink

* As the internal WLAN adapter is used for `ap0`, you will need a USB-WLAN Dongle. Be warned: USB WLAN dongles that have stable linux kernel (module) support are **not easy to find**. They tend to keep the same product name even when the producer switches to a new chipset. Oh my.
* Please connect the usb dongle to the raspi in a way that the antenna is **about 1m away** of it to prevent too much interference with the onboard `ap0`
* I have not experimented yet with the auto channel options of hostapd, so the channel defined by your wlan uplink **might be the same or very close to the one of hostapd**. You will have to edit `/etc/hostapd/hostapd.conf` to set the `channel` to a more appropriate value. I usually use the [Farproc Wifi Analyzer](https://play.google.com/store/apps/details?id=com.farproc.wifi.analyzer) on my Android mobile to find the best channel. AFAIK iOS does not expose the needed information to application programmers, so there is no similar app for iPhones.
* as all interfaces (except `ap0`) are still under control of `dhcpcd` as in standard Raspbian bullseye, you **configure the uplink SSID and password as usual** in `/etc/wpa_supplicant/wpa_supplicant.conf`. In order to bootstrap the uplink, you can either connect to the raspi using the WLAN on `ap0`, edit the file and then `systemctl restart dhcpcd` (or replug the USB dongle). Or you remove the SD-card from the raspi and write a `wpa_supplicant.conf` file to the boot partition. This file will be moved to `/etc/wpa_supplicant/wpa_supplicant.conf` upon next boot.

## IPv6 support

In order to fully work as an IPv6 gateway, we need IPv6 connectivity and a subnet for the `ap0` subnet from upstream. Some providers don't deliver IPv6 at all, others just one `/128` address, others a `/64` subnet (with all adresses routed), and only a few what should be standard: You can request a larger subnet (up to `/48`) via [DHCPv6 prefix delegation](https://en.wikipedia.org/wiki/Prefix_delegation). And the options differ massively depending on the country and for resident and mobile internet connections.

The simplest way for a solution that works everywhere is an IPv6 tunnel with a reasonable subnet. I use an openVPN tunnel to a server I control myself for this purpose, but there are dozens of other options.
