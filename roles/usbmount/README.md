# usbmount

This role configures the raspi to mount any usb disk (partition) automatically after plug in.

* All mounts are **read only** This allows to unplug the mounted disk at any time without risk of data loss.

* The **mount points** are
  * usually`/media/usb0` to `media/usb7`.
  * If you have a UUID based entry in `/etc/fstab` (that ist proven to work with a manual `mount` command), `usbmount` will use that mountpoint instead.

## Example entry `/etc/fstab`

This entry enables the disk either to be mounted normally at boot, or, if it' is not connected, the boot to continue normally without it.

When you plug in the disk later, it will be mounted. In any case, the mount point will be the same.

```
UUID=0d547008-b442-4336-96c6-769f3ebb5a7e /media/mysound ext4 defaults,ro,nofail 0 0
```

  

## Implementation details

I use the most current version of the `usbmount` debian package I was able to find. To be safe from this package to be removed from its link and being less than 20K in size, I put a copy into my repo from [here](https://github.com/nicokaiser/usbmount/releases/download/0.0.24/usbmount_0.0.24_all.deb)

I was too lazy to recreate the `deb`, so the [bugfix](https://github.com/nicokaiser/usbmount/pull/1) is applied after install with an ansible `patch` task.
