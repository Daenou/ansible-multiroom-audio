# ansible-multiroom-audio

Contains the following roles
* base
  * Installs and configures the alsa config in /etc/asound.conf, needed for ALL alsa devices
* snapserver
  * Installs the snapserver package and configures it
* snapclient
  * Installs the snapclient package and configures it to listen to a snapserver
* acable
  * Installs a systemd unit template with which you can create 'virtual cables' between alsa audio sources and sinks
  * These virtual cables are basically arec | aplay commands with configurable variables
* snd_aloop
  * Loads the `snd_aloop` kernel module for the use of alsa loopback devices
* a2dp_agent
  * Based on mill1000's [python a2dp-agent](https://gist.github.com/mill1000/74c7473ee3b4a5b13f6325e9994ff84c)
  * Installs mill1000's a2dp-agent.py script and configures a systemd unit
  * The a2dp agent handles the bluetooth connection initiation and authentication
* bluealsa
  * Installs and configures bluealsa aka [bluez-alsa](https://github.com/Arkq/bluez-alsa), which configures the device as a bluetooth audio sink aka bluetooth loudspeaker

# Requirements
- ansible installed (This playbook was tested on ansible 2.10.8)
- ansible community.general collection for community.general.modprobe
  - Install with `ansible-galaxy collection install community.general`.
- passwordless login to clients in the inventory file
- Either python2 or python3 for the a2dp_agent role

# Howto
## Config
1) Populate the variables in the `host_vars/$HOSTGROUPNAME/main.yml` files with your settings. See `roles/*/defaults/main.yml` for all variables.
2) Populate the `inventory` file with a `[snapclient]` and `[snapservers]` hostgroup and list all snapclients/servers you want to target

## Deployment
In the docroot of the playbook, do the following to execute the playbook against the inventory file `./inventory` in check mode showing what would be done (`--diff`).
To actually execute the changes remove the `--check`.
```
#snapclients.yml
ansible-playbook snapclients.yml --diff --check -i inventory
#snapservers.yml
ansible-playbook snapservers.yml --diff --check -i inventory
```

Work in progress
