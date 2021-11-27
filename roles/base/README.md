# base

This role configures `/etc/asound.conf` to set the default audio format and rate for `dmix`/`dsnoop` alsa devices. 

As the multiroom architecture makes heavy use of these devices, this minimizes the risk of wrong and incompatible defaults chosen by some of the alsa clients. This could cause audio issues that are hard to reproduce and debug.

Ansible variables available are: 
`base_audio_rate:` Leave at its default of `44100`. 
`base_audio_format:` Leavt at its default of `S16_LE`.

