# acable

This role provides a single script `/usr/local/bin/acable.sh` and some generic ansible variables that allow
you to instantiate as many "alsa cables" (i.e. permanent connections from alsa sources to alsa sinks) as you need 
for your specific setup.  Together with `snd_aloop`, arbitrarily complex setups can be built. 

The developers of this setup are kind of aware that all that cabling could probably done by a sophisticated 
`/etc/asound.conf`. But until now, we were not able to decrypt the huge amount of documentation found to create
a simple framework that lets you plug your alsa devices together arbitrarily in an understandable way.

## acable.sh

This script is run as daemon(s) by the `systemd` units created by the ansible configuration. Let's make an 
example for a development Raspberry `pidev`:

~~~
host_vars/pidev.yml

acable_connections:
  - analogdirect

acable_config:
  analogdirect:
    source: dsnoop:CARD=sndrpihifiberry,DEV=0
    sink: dmix:CARD=sndrpihifiberry,DEV=0
~~~

This creates a virtual alsa cable copying everything from the hardware `dsnoop` to the hardware `dmix` device. While
the use case for such a configuration may be limited, it is still a good test for your sound setup :smile:. By the 
way: this would be equivalent to the following `alsaloop`, but `alsaloop` does not work with `dsnoop` and/or `dmix` 
devices.

~~~
/usr/bin/alsaloop -C dsnoop:CARD=sndrpihifiberry,DEV=0 -P dmix:CARD=sndrpihifiberry,DEV=0
~~~

### bluetooth

There are two reserved names that are needed for bluetooth audio sources. Do not define the `source:` ansible variable for a bluetooth A2DP source in your host- or group- variables - it would be ignored. A2DP sources as presented by bluealsa have the bluetooth MAC address of the client in the alsa device name. Therefore, the source needs to be determined dynamically. This can be done in two different ways:

* `bluealsa-cable`: Uses `bluealsa-aplay` to read from any (even multiple?) A2DP source.
* `bluealsa-workaround-cable`: Polls every second with `bluetoothctl` to determine if there is a connected A2DP source and then uses `arecord` to capture from `bluealsa`. Functionally equivalent to `bluealsa-cable` except that only one A2DP source can be played at the same time. Ugly, but was needed to make audio work with a Nokia 7 Plus, but there may be other buggy Bluetooth Implementations out there. A nice improvement would be to replace the polling by a proper D-Bus solution.

