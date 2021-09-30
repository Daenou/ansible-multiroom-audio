# ansible-role-snapclient

Installs the snapclient package using apt and configures it to listen to a snapserver.

# Requirements
- ansible installed (This playbook was tested on ansible 2.10.8)
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
