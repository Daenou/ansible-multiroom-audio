# ansible-multiroom-audio

Contains multiple roles
* base
  * Installs and configures /etc/asound.conf, needed for both snapclients and snapservers
* snapserver
  * Installs the snapserver package and configures it
* snapclient
  * Installs the snapclient package and configures it to listen to a snapserver
* alooper
  * Loads the `snd_aloop` kernel module for alsa loopback devices and installs a systemd unit with which you can record differend alsa sources into the loopback sink. You can then point your snapserver to the loopback source and can listen to all your inputs simultaneously, eliminating the need for source switching if you only need one snap "audio channel".
* a2dp-agent
  * Based on mill1000's [python a2dp-agent](https://gist.github.com/mill1000/74c7473ee3b4a5b13f6325e9994ff84c), which configures your device as a bluetooth audio sink with [bluez-alsa](https://github.com/Arkq/bluez-alsa) aka bluealsa.
  * Installs mill1000's a2dp-agent.py script and configures a systemd unit.

# Requirements
- ansible installed (This playbook was tested on ansible 2.10.8)
- ansible community.general collection for community.general.modprobe
  - Install with `ansible-galaxy collection install community.general`.
- passwordless login to clients in the inventory file
- Either python2 or python3 for the a2dp-agent role

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
