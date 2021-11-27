# base

This roles installs a snapserver on the current host. The following ansible variables are available:

* `snapserver_name:` An arbitrary name. **TODO** check where this is actually visible.
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


