# ansible-multiroom-audio
This collection has been built to maintain (at least) two quite different multiroom audio setups based on Raspberry Pi and high quality audio HATs. We use [hifiberry](https://www.hifiberry.com/), but this works with any supported audio HAT. We are happy to hear from anyone else being successful using these roles.

## Features 

The roles support setting up an audio multiroom system from a collection of Raspberry Pis. We try to make available all audio sources, so you can

* use every Pi as bluetooth sink to stream audio e.g. from your mobile
* use the analog input to stream audio from e.g. the rec out of your hifi amp
* use the USB ports to stream audio from e.g. a turntable with a builtin USB-Soundcard

## Architecture

### Hardware Limitations

Hardware sources and sinks need to be **driven individually**, so that we can receive audio from the analog input, digitize it, stream it synchronously 
over the network to (all other clients and) the local client that sends the audio to the analog output. This will have some delay,  but exactly the same delay 
as all other networked clients. On the other hand, a soundcard has one global digital clock for all inputs/outputs. Therefore, we use only one digital audio 
format in all components and set that format explicitly wherever possible. This also minimizes the CPU load (and audio quality loss) for unwanted format 
conversions.

ALSA **dmix** devices can be used to mix multiple streams together (provided that all streams have the same digital audio format) without any conversion. 
**dsnoop** devices can be used to consume the same audio stream by multiple recorders. `dmix`/`dsnoop` devices proved to be very useful, but they are
apparently not usable for `alsaloop` as sinks/sources.

In order to support multiple audio inputs and mix them with a `dmix` device, we use the **snd_aloop** 
kernel module. This creates a virtual soundcard and whatever you stream to `dmix:CARD=Loopback,DEV=0` comes out of `device=dsnoop:CARD=Loopback,DEV=1` 
(and 1->2 and 2->3 etc). To make that work without any audio stuttering or other issues, the default audio format for `dmix`/`dsnoop` has to be set
in `/etc/asound.conf`.

### Design Goals 
Implementation on Pi

* minimal: e.g. use only ALSA 
* generic: use all interfaces without limitations (e.g. a node can be both source and sink)

Ansible implementation

* support a wide range of configurations 
* roles should be generic enough that end users have to supply only
  * an `inventory` mapping Pi hosts to `group_vars`
  * a `playbook` mapping roles to hosts or host groups
  * maybe some own `host_vars`/`group_vars`
* Fully automated setup

# Roles
* base (**TODO** rename) 
  * Installs and configures the alsa config in /etc/asound.conf, needed as soon as you use `dmix` or `dsnoop` devices. That means always.
* snapclient
  * Installs the snapclient package and configures one or more snapclients. Always (or at least on two nodes)
* snapserver
  * Installs the snapserver package and configures it (max 1 snapserver per host)
* snapweb
  * Adds a web application (on port `1780`) to snapserver that allows to control the snapclient volumes with a browser.
* acable
  * Installs a systemd unit template with which you can create 'virtual cables' between alsa audio sources and sinks
  * These virtual cables are `arec | aplay` commands with configurable variables (e.g. an `alsaloop` that can use `dmix`/`dsnoop` devices)
  * Can also create a bluetooth sink, but only when the additional role `bluetooth_sink` is also mapped to that node.
* bluetooth_sink
  * To be run after `acable`.
  * Installs and configures all components needed to enable `acable`  to accept an audio stream via bluetooth A2DP:
    * `bluetoothd` drives the hardware
    * a2dp_agent
      * Taken from mill1000's [python a2dp-agent](https://gist.github.com/mill1000/74c7473ee3b4a5b13f6325e9994ff84c)
      * Installs `a2dp-agent.py` configures a systemd unit
      * The a2dp agent handles the bluetooth connection initiation and authentication
    * bluealsa
      * Installs and configures bluealsa aka [bluez-alsa](https://github.com/Arkq/bluez-alsa), which configures the device as a bluetooth audio sink aka bluetooth loudspeaker
  * Ensures that bluetooth hardware is disabled (using `rfkill`) if not used
  * **WARNING**: There is still bug [#14](https://github.com/Daenou/ansible-multiroom-audio/issues/14), needs a one time manual intervention. 
* bluetooth_disable
  * Disable bluetooth with `rfkill`. Needed as separate role to handle devices without `acable` at all.
* snd_aloop
  * Loads the `snd_aloop` kernel module for the use of alsa loopback devices
* mpd
  * A simple mpd config, used as (additional) audio stream to snapserver
* raspotify
  * A simple (passwordless) raspotify configuration, used as (additional) audio stream to snapserver. Makes the multiroom system available to the spotify app as a speaker - provided you have a Spotify Premium account. This is a known limitation of [librespot](https://github.com/librespot-org/librespot), the code that actually makes your system talk to the spotify servers.

# Requirements
Ansible host:

* ansible installed (This playbook was tested on ansible 2.10.8)
* ansible galaxy `community.general` collection for `community.general.modprobe`, install with `ansible-galaxy collection install community.general`.
* ansible galaxy `t2d.raspotify` role as base for the raspotify role here, install with `ansible-galaxy install t2d.raspotify`.

Pi:

* bullseye image with buster repo added (bug [#18](https://github.com/Daenou/ansible-multiroom-audio/issues/18)).
* passwordless ssh login from ansible host to hostname in the inventory file. If you use passwordless login to the user `pi` (and not `root`) append `-u pi` to the command line.
* Strongly suggested: The Pis can reach each other using a DNS-Name.
* audio HAT is working and enabled in `/boot/config.txt`. You should see it with `aplay -L`
* Either python2 or python3 for the bluetooth_sink role (a2dp_agent) 

Your Environment:
* A mobile phone or a computer to control the snapclient volumes and mpd.
* A Spotify premium account if you want to use your multiroom system as Spotify speaker.
* Some pairs of decent loudspeakers (and a `hifiberry` AMP module) or a stereo amp with independent source (i.e. main out) and rec out selectors (and a `hifiberry` DAC/ADC module). 

# Howto
## Config
1) Populate the variables in the `host_vars/$HOSTGROUPNAME/main.yml` files with your settings. Checkout `roles/*/defaults/main.yml` to see all variables available.

2) Populate the `inventory` file with a `[snapclient]` and `[snapservers]` hostgroup and list all snapclients/servers you want to target
3) Write a playbook

A working example uses the following files (**TODO** change this before going to ansible galaxy):
* Playbook: `multiroom-amsel.yml`
* Inventory: `inventory_amsel`
* Group vars: `group_vars/amsel*`

## Deployment
(**TODO** change this before going to ansible galaxy)

In the docroot of this repo, do the following (in check mode). 

```
ansible-playbook multiroom-amsel.yml --check --diff -u pi -i inventory_amsel
```

* To apply the changes (and not only check), remove `--check` from the command line. 
* If your passwordless login makes you `root` on the Pi (and not `pi`), remove `-u pi` from the command line
