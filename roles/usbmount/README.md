# usbmount
This role configures the raspi to mount any usb disk (partition) automatically after plug in. If installed together with `mpd`, the devices are automatically scanned by mpd so that you can browse the music in an mpd client.

* All automatic mounts are **read only**. Therefore you can unplug the device at any time.
* The **mount points** are `/media/usb0` to `/media/usb7`.
* If the directory `/var/lib/mpd/music/` exists
  * a new subdirectory `temp` is created.
  * The usbmount configuration is enhanced to 
    * create a symlink from `/var/lib/mpd/music/temp/NAME_OF_DEVICE` to `/media/usbX` and **trigger mpd to add the files in the new directory to its database** after a mount.
    * remove that symlink and trigger mpd to remove the files from its database
* As this adding / removing files from mpd scales well for smaller disks, it can take dozens of minutes on a large collection.  If you have a UUID based entry in `/etc/fstab` (that works with a manual `mount` command), `usbmount` will use that mountpoint instead. This establishes a stable mount point for your favourite devices and will **not trigger mpd** on plug or unplug and enables / forces you to manage the mpd scan manually.

## Example entry `/etc/fstab`

```
UUID=0d547008-b442-4336-96c6-769f3ebb5a7e /media/mysound ext4 defaults,ro,nofail 0 0
```

With this entry, the normal boot will attempt to mount the device at `/media/mysound` if it is present and continue silently if not. After boot, as soon as you plug in the device, `usbmount` will mount it automatically to the same mount point.

* if `usbmount` is already active, it might interfere with your manual actions. You can disable `usbmount` by setting `ENABLED=0` in `/etc/usbmount/usbmount.conf`
* find out the correct UUID: plug in your device and try e.g. `ls -l /dev/disk/by-uuid/`
* create the mount point: `mkdir /media/mysound`
* create the entry in `/etc/fstab` and verify with `mount /media/mysound` that the entry works. `ext4` is probably not the filesystem on your usb device,  but **`ro,nofail 0 0` are mandatory** to keep user experience consistent.
* test it: reboot with disk connected, reboot without, connect later.

## Implementation details

I use the most current version of the `usbmount` debian package I was able to find. To be safe from this package to be removed from its link and being less than 20K in size, I decided to use a copy from [here](https://github.com/nicokaiser/usbmount/releases/download/0.0.24/usbmount_0.0.24_all.deb) and store it in this repo here.

I was too lazy to recreate the `deb`, so the [bugfix](https://github.com/nicokaiser/usbmount/pull/1) is applied after install with an ansible `patch` task.
