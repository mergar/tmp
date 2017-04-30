#!/bin/sh

ToritoSize=`du -s /root/refind-net | cut -f 1`
ToritoSize=$(( ToritoSize / 28 ))
ToritoSize=$(( ToritoSize *32 ))

echo $ToritoSize

dd if=/dev/zero of=efi.fs bs=1024 count=$ToritoSize


