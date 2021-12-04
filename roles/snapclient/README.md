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

* `name:` is used for ansible output, for the instance names of the respective systemd service instances and to name the config files in `/etc/snapclient.conf/d`. Keep them short, lowercase, only `a..z` please.
* `snapclient_snapserver:` The IP address or the DNS name of the `snapserver` you want to connect to, e.g. `192.168.1.14`.
* `snapclient_sink:` The alsa sink you want to play the sound to. Should be hardware, as any further audio routing would probably ruin the synchronous multiroom experience. E.g. `dmix:CARD=sndrpihifiberry,DEV=0`.

Implementation hints:
* In order to support multiple instances in a scalable way, the systemd service delivered from the `snapclient` debian package is masked and in `/etc/default/snapclient` `START_SNAPCLIENT` is set to `false` by the role.
* If you remove a snapclient instance from `snapclient_config` and rerun the playbook, the corresponding config file and service instance created by the first run (or manually matching the generic pattern) are **automatically removed**. This allows you to easily remove or rename a snapclient instance without manual cleanup.
