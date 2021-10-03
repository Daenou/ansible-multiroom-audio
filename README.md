# ansible-multiroom-audio

Contains multiple roles
* snapserver
  * Installs the snapserver package and configures it
* snapclient
  * Installs the snapclient package and configures it to listen to a snapserver
* aloopplay
  * Loads the `snd_aloop` kernel module for alsa loopback devices and installs a systemd unit with which you can record differend alsa sources into the loopback sink. You can then point your snapserver to the loopback source and can listen to all your inputs simultaneously, eliminating the need for source switching if you only need one snap "audio channel".
 
# Requirements
- ansible installed (This playbook was tested on ansible 2.10.8)
- ansible community.general collection for community.general.modprobe
  - Install with `ansible-galaxy collection install community.general`.
- passwordless login to clients in the inventory file

# Howto
## Config
1) Populate the `config/defaults.yml` file with your settings
2) Populate the `inventory` file with a `[snapclient]` hostgroup and list all snapclients you want to target

## Deployment
In the docroot of the playbook, do the following to execute the playbook against the inventory file `./inventory` in check mode showing what would be done (`--diff`).
To actually execute the changes remove the `--check`.
```
ansible-playbook snapclients.yml --diff --check -i inventory
```

Work in progress
