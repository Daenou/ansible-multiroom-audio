# usbmount

This role configures the raspi to automatically mount any usb disk read only. This allows to remove the usb disk at any time without risk of data loss. 

Disks are mounted below `/media/usb0` to `media/usb7`. If you make UUID based entry in `/etc/fstab`, you can define the mount point:

```
UUID=0d547008-b442-4336-96c6-769f3ebb5a7e /media/mysound ext4 defaults,ro,nofail 0 0
```

This enables the disk to be mounted normally at boot by the normal bootup process or, if not connected, the boot to continue normally. If you plug in the disk later, it will be mounted. In any case, the mount point is the same.

## Implementation details

I use the most current version of the `usbmount` debian package I was able to find. To be safe from this package to be removed from its link and being less than 20K in size, I put a copy into my repo from [here](https://github.com/nicokaiser/usbmount/releases/download/0.0.24/usbmount_0.0.24_all.deb)

I was too lazy to recreate the `deb`, so the [bugfix](https://github.com/nicokaiser/usbmount/pull/1) is applied after install with an ansible `patch` task.
