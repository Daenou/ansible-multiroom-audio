# ansible-role-snapclient

Installs the snapclient package using apt and configures it to listen to a snapserver.

# Requirements
- ansible v2.9 installed
- passwordless login to clients in the inventory file

# Howto

In the docroot of the playbook, do the following to execute the playbook against the inventory file `./inventory` in check mode showing what would be done (`--diff`).
To actually execute the changes remove the `--check`.
```
ansible-playbook snapclients.yml --diff --check -i inventory
```

Work in progress
