# ansible-multiroom-audio

This collection has been built to maintain (at least) two quite different multiroom audio setups based on Raspberry Pi and high quality audio HATs. We use [hifiberry](https://www.hifiberry.com/), but this works with any supported audio HAT. We are happy to hear from anyone else being successfull using these roles.

The basic design goals are:
* Use only ALSA
* ansible implementation should support a wide range of configurations easily

# Roles
* base (**TODO** rename) 
  * Installs and configures the alsa config in /etc/asound.conf, needed as soon as you use `dmix` or `dsnoop` devices. That means always.
* snapclient
  * Installs the snapclient package and configures one or more snapclients 
* snapserver
  * Installs the snapserver package and configures it (max 1 snapserver per host)
* acable
  * Installs a systemd unit template with which you can create 'virtual cables' between alsa audio sources and sinks
  * These virtual cables are basically arec | aplay commands with configurable variables
  * Can also create a bluetooth sink, but only when the additional role `bluetooth_sink` is also executed on that node.
* bluetooth_sink
  * Installs and configures all components needed to enable `acable`  to accept an audio stream via bluetooth A2DP:
    * `bluetoothd` drives the hardware
    * a2dp_agent
      * Taken from mill1000's [python a2dp-agent](https://gist.github.com/mill1000/74c7473ee3b4a5b13f6325e9994ff84c)
      * Installs `a2dp-agent.py` configures a systemd unit
      * The a2dp agent handles the bluetooth connection initiation and authentication
    * bluealsa
      * Installs and configures bluealsa aka [bluez-alsa](https://github.com/Arkq/bluez-alsa), which configures the device as a bluetooth audio sink aka bluetooth loudspeaker
* snd_aloop
  * Loads the `snd_aloop` kernel module for the use of alsa loopback devices

# Requirements
- ansible installed (This playbook was tested on ansible 2.10.8)
- ansible community.general collection for community.general.modprobe
  - Install with `ansible-galaxy collection install community.general`.
- passwordless login to clients in the inventory file. If you use passwordless login to the user `pi` (and not `root`) append `-u pi` to the command line.
- Either python2 or python3 for the a2dp_agent role

# Howto
## Config
1) Populate the variables in the `host_vars/$HOSTGROUPNAME/main.yml` files with your settings. Refer **TODO** to `example` for examples and to `roles/*/defaults/main.yml` to see all variables
2) Populate the `inventory` file with a `[snapclient]` and `[snapservers]` hostgroup and list all snapclients/servers you want to target

## Deployment
**TODO** decide where to put the examples 

In the docroot of the playbook, do the following to execute the playbook against the inventory file `./inventory` in check mode showing what would be done (`--diff`).
To actually execute the changes remove the `--check`. 
```
#snapclients.yml
ansible-playbook snapclients.yml --diff --check -i inventory
#snapservers.yml
ansible-playbook snapservers.yml --diff --check -i inventory
```

