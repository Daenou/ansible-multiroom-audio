# raspotify

This role installs [librespot](https://github.com/librespot-org/librespot), 
an open source implementation for [Spotify Connect](https://support.spotify.com/article/spotify-connect/)
on the target node.

**WARNING**: librespot needs a *Spotify Premium* account, this is 
a limitation enforced by Spotify.

There are basically two different configurations for librespot.
Either you configure the user account into the configuration 
or you have working mDNS (a.k.a. avahi/Bonjour/...).

* **with user account**: when you are logged in to your 
  spotify app with the same account, you will be able
  to use raspotify as audio sink. The app and the raspotify
  sink can be in arbitrary, disjoint networks (as long as 
  both reach the internet).

* **with mDNS**: Any spotify app in the same network can use
  this raspotify sink, the raspotify configuration is account
  agnostic.

The latter option is the only one available via this ansible role.
It is much more generic and usually runs out of the box. However, 
when the raspi is both a router and music box
at the same time, a firewall (see the [uplink role](../uplink/README.md))
is implemented. The spotify port must be unfirewalled explicitly now - 
this was not needed as long as the Raspberry Pi was not a router.

Therefore, the default librespot approach of choosing randomly
a port on startup does not work any more.

## Variables

* `raspotify_name`: The device name seen in the spotify app (` (hostname)` always appended)
* `raspotify_verbose`: Enable more verbose logging (search for `librespot` in `/var/log/daemon.log`)
* `raspotify_bitrate`: role default `320`.
* `raspotify_device_type`: role default `speaker`.
* `raspotify_backend`: role default `alsa`
* `raspotify_format`: output format, must match the ALSA system settings, role default `S16`
* `raspotify_device`: The alsa sink, role default `dmix:CARD=Loopback,DEV=0`
* `raspotify_zeroconf_port`: The TCP port where raspotify will accept connects from clients. This option 

  * should **not** be set for a simple audio sink that is **not** a router at the same time.
  * **must be set** when using the `raspotify` role together with the `uplink` role. And that chosen port must be opened by the firewall of the `uplink` role. It is your responsibility to choose an appropriate port.

## Implementation hint

Due to a bug I was unable to track down in raspotify, mDNS of raspotify does not 
work on the WLAN side (`ap0`) created with the `accesspoint` role. Therefore, 
an additional avahi file is distributed that causes avahi to announce the missing
information instead.

