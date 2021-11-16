# snapclient

This role configures a `snapclient` on the target host. There are two ansible variables to configure it (e.g. in `host_vars`):

* `snapclient_snapserver:` The IP-Adress or the DNS-Name of the `snapserver` you want to connect to, e.g. `192.168.1.20` 
* `snapclient_sink:` The alsa sink you want to play the sound to. Should be hardware, as any further audio routing would probably ruin the synchronous multiroom experience. E.g. `dmix:CARD=sndrpihifiberry,DEV=0` 

