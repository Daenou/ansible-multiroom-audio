# bluetooth_sink

Installs and configures the 3 components to make the special `bluetooth*` `acable` names actually work. In order to actually implement a bluetooth sink, you will need in addition a properly configured `acable`. These are

* **bluetoothd**: usually already installed, but configured to be visible forever for new clients (insecure!)
* **a2dp_agent**: Authenticates all incoming A2DP bluetooth pairing requests (insecure!)
* **bluealsa**: Reads the A2DP audio stream and makes it available as ALSA source.

Currently, none of these three components has any ansible variables to configure it. 

## bluetoothd

This daemon drives the bluetooth hardware. 

**WARNING** The role configures bluetooth to be in `pairable` mode forever. This is very handy (as any device can simply connect), but completely insecure.

## a2dp_agent

Installs and configures the `a2dp_agent`, a simple bluetooth agent written in python. 
Thanks go to [mill1000](https://gist.github.com/mill1000/74c7473ee3b4a5b13f6325e9994ff84c) for this one.

A bluetooth agent is a separate process talking to `bluetoothd` (like `bluetoothctl`) and handles the 
**pairing** (and unpairing etc.) to remote bluetooth devices: It is used to establish both trust and a connection
with one or more profiles between the local and remote bluetooth devices. It does **not** transport any payload data itself.

The `a2dp-agent` authenticates any incoming connection as long as it is an `A2DP` connection. The [Advanced Audio Distribution Profile](https://en.wikipedia.org/wiki/List_of_Bluetooth_profiles#Advanced_Audio_Distribution_Profile_(A2DP) is the way you should send HiFi-Audio over bluetooth.

## bluealsa

Installs and configures the `bluealsa` daemon. 

This daemon can read the audio stream from all connected bluetooth A2DP audio sources and creates a virtual alsa sound card for each of them. 


