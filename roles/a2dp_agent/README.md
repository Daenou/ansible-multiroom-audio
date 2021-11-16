# a2dp_agent

Installs and configures the `a2dp_agent`, a simple bluetooth agent written in python. 
Thanks go to [mill1000](https://gist.github.com/mill1000/74c7473ee3b4a5b13f6325e9994ff84c) for this one.

A bluetooth agent is a separate process talking to `bluetoothd` (like `bluetoothctl`) and handles the 
**pairing** (and unpairing etc.) to remote bluetooth devices: What device do I trust, what kind of data
exchange will be established. It does **not** transport any data itself.

This agent authenticates any incoming connection as long as it is an `A2DP` connection. The [Advanced Audio Distribution Profile](https://en.wikipedia.org/wiki/List_of_Bluetooth_profiles#Advanced_Audio_Distribution_Profile_(A2DP)) is the way you should send HiFi-Audio over bluetooth.

Required to play an audio stream from a bluetooth device (like a mobile phone) to the multiroom system, but not sufficient (needs 2 other roles and an `acable`).


