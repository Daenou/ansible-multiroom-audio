# snapweb

This roles installs [snapweb](https://github.com/badaix/snapweb) in addition to snapserver on the current host. 

There is currently no precompiled version available, the installation is usually manually done (on the raspi) by:

~~~
apt install wget node-typescript

wget https://github.com/badaix/snapweb/archive/refs/heads/master.zip
unzip master.zip
cd snapweb-master/
make
mv dist /usr/share/snapserver/snapweb
~~~

It would be possible to implement this in ansible, but it would be quite slow and not idempotent at all.

**TODO** The current implementation drops files that have been copied into git after being generated on a raspi (Pi 4B, v7l, Kernel 5.10, bullseye). The files are organized for now by the snapweb version as found in `page/index.html` and a date
of the compilation, e.g. 20211206_0.3.0.

This is the configuration variable `snapweb_srcdir`

Please report if these files don't work on your equipement, we are happy to make a more elaborated directory structure.

The following target files are dynamically created by `tsc` from the contents of the `page/` directory:

~~~
config.js
config.js.map
snapcontrol.js
snapcontrol.js.map
snapstream.js
snapstream.js.map
~~~

The following target files are simply copied by the `Makefile`:

~~~
3rd-party/libflac.js
favicon.ico
index.html
launcher-icon.png
manifest.json
mute_icon.png
play.png
speaker_icon.png
stop.png
styles.css
~~~

