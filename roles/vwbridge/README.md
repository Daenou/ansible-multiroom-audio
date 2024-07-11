# vwbridge

## experimental

* only tested on `bookworm`, uses `nmcli` exclusively for all network configuration
* very specific use case: WLAN traffic on separate VLAN
* conflicts with the `uplink`/`accesspoint` roles
* only creates, never cleans up/modifies (until now).
* there are bugs in older versions of `community.general.nmcli`, i had success after
upgrading to `8.6.0`. Try `ansible-galaxy collection install community.general --upgrade` if in doubt.

The role does not check for conflicts with other NetworkManager
`wifi` connections. Please
ensure that there is **no other wifi connection** defined on the target.
If `nmcli c` still shows one or more connections of type `wifi`, delete
them one by one with `nmcli c delete ...` first.

## use case

You have multiroom and WLAN in your place, but there is that one room that
has an ethernet connected multiroom device, but the wireless signal is just
not strong enough in that room. Or there is another multiroom device
next door just a bit too far from your WLAN.

There is a separate subnet for wireless traffic that is available
as a VLAN on the ethernet interface. This VLAN has also a working
auto configuration setup for IPv4 and/or IPv6 (DHCP, SLAAC, ...).

## implementation

The role

* creates a VLAN interface
* creates wifi ap interface (tested with WPA PSK)
* bridges those two together

None of those interfaces gets an IP configuration, this is pure layer 2
magic. Wireless clients connecting to this AP get their IPv4/v6 configuration
via the same mechanisms as the ones connecting to your "main" access point.

You can therefore use the same SSID as your main access point (but then you should
also use the same pre shared key). This should give you some automatic failover.
If you chose a different SSID, you need to decide what client connects to what
SSID.

Ansible variables to set (there are no defaults) for the vlan:

* `vwbridge_vlan_if`: The name of your ethernet interface, usually `eth0`
* `vwbridge_vlan`: set to your VLAN number, e.g. 800

and for the wifi ap configuration:

* `vwbridge_wifi_if`: The name of your wifi interface, usually `wlan0`
* `vwbridge_wifi_ssid`: the wireless SSID (a.k.a. wifi name) you want to announce
* `vwbridge_wifi_dict`: the configuration of the `wifi` entry in ansible task.
   See [nmcli documentation](https://docs.ansible.com/ansible/latest/collections/community/general/nmcli_module.html). Setting `mode: ap` is the bare minimum you need, you may want to add e.g. `band: bg` and `channel: 3` to select channel 3 in the 2.4GHz band.
* `vwbridge_wifi_sec_psk`: your wireless pre shared key (a.k.a. password) the wifi clients need to connect to. Do not store your key in plain, ask e.g. interactively in the playbook for it.
* `vwbridge_wifi_sec_pmf`: configure the `wifi_sec.pmf` (Protected Management Frames) setting. I set it `1` (disable) to allow an older device to connect.
* `vwbridge_wifi_sec_protos`: This is a list of strings, `rsn` and `wpa` are the only allowed values. I could not connect from a RaspberryPi Zero 1.1 to a `rsn` only access point, but (with the same 32bit bookworm sdcard) in a RaspberryPi Zero 2, it worked. Maybe playing with the [ccmp](https://askubuntu.com/questions/1345284/how-to-disable-wpa1-security-and-keep-only-wpa2-aes-wifi-hotspot-on-ubuntu-18-04) and [tkip](https://variwiki.com/index.php?title=Wifi_NetworkManager#Configuring_WiFi_Access_Point) settings could help, but I did not test this.

See [this example](/group_vars/amsel_wifi_bridges/main.yml) for reference.

Don't forget to ensure that your wifi interface is not used for anything else **before** applying this role
as described above.

## run

Using a different playbook for this role allows to ask for the wifi password
only when needed:

~~~
ansible-playbook vwbridge_amsel.yml -CD -u pi -i inventory_amsel
~~~

## hints for an implementation without VLAN

If you want to bridge the wireless interface to your wired
interface directly (without VLAN), you will need to do that
manually or write a different role. As this will mess with
your main uplink interface `eth0` directly, you will have
to test that carefully and probably connect a keyboard/screen
to the raspi. The architecture will be

* `wifibridge`: as is
   * `brelay`: as is
   * `eth0`: will need to be modified to become bridge member

Usually, you should put the IP-adress to the `wifibridge` and leave `eth0` unconfigured
so that the bridge is addressable independent of the available bridge members. But
in this use case the reachability of `eth0` is more important. Please test and
get used to `nmcli`.
