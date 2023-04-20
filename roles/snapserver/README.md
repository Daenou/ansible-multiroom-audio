# snapserver

This roles installs a snapserver on the current host. The following ansible variables are available:

* `snapserver_name:` An arbitrary name. This name is visible e.g. in snapweb.
* `snapserver_sourcetype:` Only value currently supported and tested: `alsa`
* `snapserver_alsasource:` Where does Snapserver get its audio signal from? Usually `dsnoop:CARD=Loopback,DEV=1` as this is where the analog, mpd and probably bluetooth audio will be sent to.
* `snapserver_sampleformat:` Use the default `44100:16:2` except you really know what you are doing.
* `snapserver_codec`: Use the default `flac` except you really know what you are doing.
* `snapserver_buffer`: **TODO** the current default value of `200` seems to be ignored by snapserver, see below

~~~
Nov 25 20:32:49 pidev snapserver[12587]: Adding service 'Snapcast'
Nov 25 20:32:49 pidev snapserver[12587]: Buffer is less than 400ms, changing to 400ms
Nov 25 20:32:49 pidev snapserver[12587]: PcmStream: sspidev, sampleFormat: 44100:16:2
~~~

Two features I really like are not available from the snapserver version
in the bullseye version. By setting one control variable, you can make
the snapserver role to use the [package published on github](https://github.com/badaix/snapcast/releases)
as package source.

**Please note**: if you switch from the raspbian to the github version, you
need to manually remove `/var/lib/snapserver/` **before** you let the playbook
install the package.

* `snapserver_from_github`: set to true to enable to fetch the package from github
* `snapserver_github_source`: set in defaults to the latest version
* `snapserver_github_dest`: set in defaults to `/tmp/...`
* `snapserver_github_sha256sum`: Checksum of the package file
* `snapserver_idle_threshold`: snapserver switches to "silence" when audio is below the silence level for longer than the amount of milliseconds
* `snapserver_idle_percent`: the maximum audio level in percent that is still considered as silence
* `snapserver_initial_volume`: the volume a new (i.e. unknown in `/var/lib/snapserver/server.json`) snapclient gets assigned to.
