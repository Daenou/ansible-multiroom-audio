# mpd

This role installs and configures an mpd on the host. The current configuration template is taken from the package default `mpd.conf` (with all comments and most whitespace removed). These ansible variables are available:

* `mpd_enable_zeroconf:` `true` or `false`, defaulting to `false`. Note that enabling zeroconf and having a systemd socket at the same time is [a pointless exercise](https://mpd-devel.musicpd.narkive.com/TNe6J7Lj/systemd-and-zeroconf-no-global-port-disabling-zeroconf): *You would only be able to find MPD after you already connected to MPD*. Therefore:
    * `true` enables zeroconf in the `mpd` configuration and disables `mpd.socket`.
    * `false` disables zerconf in the `mpd` configuration and (starts and) enables `mpd.socket`.
* `mpd_music_directory:` supported by the current template: just a local path like `/var/lib/mpd/music` or (ideally) a read only SMB guest share like `smb://myshare.mydomain.ch/music`. Can be checked e.g. with `mpc -h localhost mount`
* `mpd_max_output_buffer_size:` Defaults to `32768`, prevents issues with a large collection and certain mpd clients.
* the only mpd sink currently supported is an alsa sink, usually consumed via an ALSA loopback from the snapserver:
    * `mpd_alsa_sink_name:` an arbitrary sink name, visible e.g. with `mpc -h localhost outputs`. Defaults to `To Snapserver`.
    * `mpd_alsa_sink_device:` the alsa sink, defaults to `dmix:CARD=Loopback,DEV=0`. While this makes sense for a snapserver based setup, you might want to change this e.g. to `dmix:CARD=sndrpihifiberry,DEV=0`. Do not use `hw`, this would prevent other audio connections (e.g. via bluetooth) from accessing the alsa device.
    * `mpd_alsa_sink_format:` the format, defaults to `44100:16:2`.
    * `mpd_alsa_sink_mixer_type:` Defaults to `software`, which is appropriate when feeding audio to snapserver. In a single host setup, it makes sense to set this to `hardware`. In this case, two additional parameters are used
    * `mpd_alsa_sink_mixer_device:` Defaults to `hw:CARD=sndrpihifiberry`.
    * `mpd_alsa_sink_mixer_control:` Defaults to `Digital`.

## Mounting mpd music dir via fstab

When `mpd` encounters the music directory to start with `smb://` it uses `libsmbclient` to connect to the Samba Share. This usually works, but `libsmbclient` [is not thread safe and apparently won't ever be](https://github.com/MusicPlayerDaemon/MPD/issues/991). Therefore, there is also support for mounting the music directory via fstab (but this doesn't work anonymously).

* `mpd_smb_mount_music_dir`: defaults to `False`. If set to `True`, the following variables become important:
    * `mpd_smb_mount_music_dir_src`: The description of the remote share, e.g. `//myshare.mydomain.ch/music`
    * `mpd_smb_mount_music_dir_user`: the smb user used to logon to the Samba Share
    * `mpd_smb_mount_music_dir_password`: the password for that user. Defaults to `unset` which causes the role to interactively ask for it as long as the share is not mounted: If the share is already mounted, the credentials must be correct so there is no need to update them.
    * `mpd_smb_mount_music_dir_domain`: the Samba Domain. These three variables get written to the `/etc/mpd_mount.creds` file that will be referred to by the mount entry created in `/etc/fstab`

Note that it is an error to have `mpd_music_directory` start with `smb://` **and** setting `mpd_smb_mount_music_dir` to `True` at the same time.

## Hints to configure hardware mixing

In order to find the correct mixer device and control values, you will have to play with your audio hardware and alsa. I was successful with `amixer`. If `amixer` works, you can use the values behind `-D` and `sget` for device / mixer respectively.

```
root@camper:/home/pi# amixer -D hw:CARD=sndrpihifiberry sget Digital
Simple mixer control 'Digital',0
  Capabilities: pvolume pswitch
  Playback channels: Front Left - Front Right
  Limits: Playback 0 - 207
  Mono:
  Front Left: Playback 156 [75%] [-25.50dB] [on]
  Front Right: Playback 156 [75%] [-25.50dB] [on]
```
