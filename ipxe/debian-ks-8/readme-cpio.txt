http://forum.ipxe.org/showthread.php?tid=8275
Note the bold text above, unfortunately it is not true that the CPIO header is added (that is only done in pcbios mode when loading a bzImage, and not yet in efi mode)

For now to fix this in efi we will need to add a cpio header ourselves beforehand to preseed.cfg, todo this we use 

~~~
echo preseed.cfg | cpio -H newc -o > preseed.cfg.cpio
~~~

The echo is just to tell cpio which filename(s) it should read from.

and then update the ipxe script to use that file instead


Here we just send in our "precompiled" cpio instead of letting ipxe create it for us, this also works in legacy pcbios mode as long as we don't the second filename to the initrd line which is the trigger for creating ipxe to add the cpio header. 

