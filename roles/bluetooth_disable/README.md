# bluetooth_disable

This role disables bluetooth using `rfkill`. This is only needed
for hosts without an `acable_config`, e.g. pure snapclients
without analog / bluetooth input.

On hosts with an `acable_config`, the role `bluetooth_sink` manages
the `rfkill` settings.
