# mpdutils

This role adds some services around mpd that I found to be useful. Currently, there is only one utility:
 
* playlistbot: Checks the current playlist, can create backup copies and remove duplicates entries.

## playlistbot

Sometimes, I build quite long playlists that I don't want to lose, e.g. when other people play around with the system or when the raspi suddenly loses power. This service is enabled by default to watch the current playlist and remove all occurrences of exactly the same file / web radio link except for the first one. This is extremely helpful if you erroneously load the same playlist twice.

The playlists are saved with a generic name as mpd playlists on server side, so they are available to any mpd client.

The following variables are available:

* `mpdutils_playlistbot_maxautosave: the maximum number of playlists that are left when the bot is cleaning up the saved playlists. Defaults to `30`.
* `mpdutils_playlistbot_playlistnamebase:` the beginning of the name of the created playlists, defaults to `zz_saved_`. The second part will be a timestamp like `20220928-175631`.
* `mpdutils_playlistbot_options:` the functions to be executed when the bot is executed. Defaults to `-scd`, i.e. playlists are saved, the bot cleans up and duplicates are removed.
* `mpdutils_playlistbot_OnCalendar:` the systemd timer setting, defaults to `*-*-* *:*:00`, i.e. the bot is run about every minute.
