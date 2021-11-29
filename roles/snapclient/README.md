# snapclient

This role configures one or more snapclients on the target host. Place an ansible list to configure (e.g. in `host_vars`) like this:

~~~
snapclient_config:
  - name: pidev
    snapclient_snapserver: pidev.example.net
    snapclient_sink: dmix:CARD=sndrpihifiberry,DEV=0
  - name: otherpi
    snapclient_snapserver: 192.168.1.14
    snapclient_sink: dmix:CARD=sndrpihifiberry,DEV=0
~~~

Where 

* `name:` is used for ansible output and for the instance names of the respective systemd service instances and to name the config files in `/etc/snapclient.conf/d`. Keep them short, lowercase, only `a..z` please.
* `snapclient_snapserver:` The IP-Adress or the DNS-Name of the `snapserver` you want to connect to, e.g. `192.168.1.14` 
* `snapclient_sink:` The alsa sink you want to play the sound to. Should be hardware, as any further audio routing would probably ruin the synchronous multiroom experience. E.g. `dmix:CARD=sndrpihifiberry,DEV=0`.

Implementation hints:
* In order to support multiple configs, the systemd service delivered from the debian package is masked and (as I am paranoid) `/etc/default/snapclient` is edited. 
* I don't know yet if it should be enforced by the ansible data structure that the `snapclient_sink` is always the same (i.e. have only one setting in `snapclient_config` instead of a setting per instance like now). For the moment, I prefer to have a uniform data structure (and the currently unneeded freedom to assign different sinks) at the price of a little redundancy (in normal) configurations. 
