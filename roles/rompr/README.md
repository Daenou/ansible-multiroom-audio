# rompr - Web Frontend for mpd

**rompr** is a beautiful web frontend for mpd, but it does not scale for long playlists/huge collections:

* Whenever you add music to your collection, you have to first reindex mpd and then reindex rompr again (rompr maintains an internal database).
* Long playlists (more 20-30 songs) from a large collection (over 100'000 songs) **do not work at all**: In order to show the current playlist, rompr does an internal database lookup for each song and if the collections is large each lookup takes up to a second so after about 90 songs the playlist does not show up any more because of a 2 minute timeout...

## implementation notes

The role uses a docker container available from github (see below). This role implements the install instructions for that container.  The first install takes over 5 minutes. Be patient. It'll work out.

You don't need to set any variable explicitly, but these are the defaults and can be overridden:

* `rompr_version` - currently set to `2.17` as this is the most current version [available upstream](https://github.com/fatg3erman/RompR/releases).
* `rompr_download_path` - currently set to `/var/tmp/git/docker-rompr`.
* `rompr_image_basename` - currently set to `local/rompr_`. Used to create the target name for a new image and to identify stale images that can be automatically removed.
* `rompr_image_name`- currently set to `{{ rompr_image_basename }}{{ rompr_version }}`. Putting the version into the image name ensures that the image is rebuilt automatically after changing the version number. As most of the image is already downloaded, such an upgrade is quite fast.
* `rompr_container_name` - currently set to `rompr`.

## global setup after installation

After installation, rompr does not work yet: The default configuration for the mpd target is `localhost`. Even when `rompr` is installed on the same node as `mpd`, `rompr` is running in a container and therefore `mpd` is locically running on a different host. This is why you see the configuration frontend of `rompr` at first connect.

You can always come back here by using the URL: `http://<your_rompr_hostname>/?setup`

And you will be sent back here automatically if the connection to `mpd` does not work.

* *Mopidy or mpd server*: set to the DNS name (or IP adress) of your mpd server. `localhost` will **not work**.
* all other settings can stay on the default

## gui configuration after installation

Once the connection to `mpd` is established, there are a lot of things you can configure in the normal GUI. I usually do the following:

* *Update Music Collection Now* This takes some time and uses quite some CPU (depending on the size of your collection).
* Hide *radio stations*, *podcasts*, *spoken word*, *personalised radio* and *info panel*
* Ignore these prefixes when sorting: *The,Der,Die,Das*

And finally, I go back to the setup and remove the config dialog (can only be reenabled in this dialogue).

## Motivation

I was (and still am) unhappy with the Android (and Linux) Apps. I hope to have found
a usable web client with `rompr`.

It would also be possible to install rompr without container from [source](https://github.com/fatg3erman/RompR), using the [install instructions](https://fatg3erman.github.io/RompR/Installation). This involves installing/configuring nginx, some php packages and sqlite as database.
