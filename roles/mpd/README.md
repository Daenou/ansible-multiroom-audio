# mpd

This role installs and configures an mpd on the host. The current configuration template is taken from the package default `mpd.conf` (with all comments an most whitespace removed). These ansible variables are available

* `mpd_music_directory`: supported by the current template: just a local path like `/var/lib/mpd/music` or (ideally) a read only SMB guest share like `smb://myshare.mydomain.ch/music`. Can be checked e.g. with `mpc -h localhost mount`
* the only mpd sink currently supported is an alsa sink, intended to be consumed via a an ALSA loopback from the snapserver: 
    * `mpd_alsa_sink_name`: an arbitrary sink name, visible e.g. with `mpc -h localhost outputs`
    * `mpd_alsa_sink_device`: the alsa sink, e.g. `dmix:CARD=Loopback,DEV=0`
    * `mpd_alsa_sink_format`: the format, e.g `44100:16:2`





