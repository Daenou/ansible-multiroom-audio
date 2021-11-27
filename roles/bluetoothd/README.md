# bluetoothd

Installs and configures the `bluetoothd` daemon. 

This daemon is needed to access the bluetooth hardware of the Raspberry Pi. `bluetoothd`is usually already part of the default installation, but this role ensures its presence and configuration.

**WARNING** The role configures bluetooth to be in `pairable` mode forever. This is very handy (as any device can simply connect), but completely insecure.

Required (together with ``bluealsa` and `a2dp_agent`) to play an audio stream from a bluetooth device (like a mobile phone) using one of the bluetooth acable configurations.

No ansible variables available.

