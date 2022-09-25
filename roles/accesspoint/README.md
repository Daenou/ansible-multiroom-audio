# accesspoint

This role configures the onboard wlan interface to act as access point. This enables the raspi to be used without internet connectivity but still use a wlan connection to control e.g. `mpd` with a mobile app. 

**WARNING:** This disables the use of the onboard wlan interface to connect as client to another access point. If you are not connected to the raspi using Ethernet (or a 2nd WLAN adapter), you will lose network connectivity.

* The onboard wlan interface is renamed to `ap0`
* `dhcpcd` is prevented from using `ap0` as this would prevent `hostapd` from managing the interface properly
* `hostapd` is used to create a WPA2 hotspot.
* `dnsmasq` is used as DHCP-Server for the WLAN clients.

Ansible variables available are

* `accesspoint_ap0_address_v4`: The static IP of your new access point, e.g. `192.168.250.1`
* `accesspoint_ap0_mask_v4`: The network mask, e.g. `255.255.255.0`
* `accesspoint_dhcp_range_v4`: The dhcp range handed out to WLAN clients, must be part of the network defined by the address/mask, e.g. `192.168.250.10,192.168.250.199`
* `accesspoint_channel`: The WLAN channel to be used by the WLAN access point, eg `11`
* `accesspoint_ieee80211d`: Enable transmission of additional network information, needs correct country code, `0` or `1`
* `accesspoint_country_code`: country code, eg `CH`
* `accesspoint_ssid`: Whatever SSID you want your WLAN to have, defaults to inventory hostname
* `accesspoint_wpa_passphrase`: Whatever WPA2 passphrase you want to set, ideally to be retrieved interactively with `vars_prompt` in the playbook.

