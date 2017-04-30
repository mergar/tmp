#!/bin/sh

DST_DIR="/tmp/chroot"

if [ -d ${DST_DIR} ]; then
	chflags -R noschg ${DST_DIR}
	rm -rf ${DST_DIR}
fi
[ ! -d ${DST_DIR} ] && mkdir -p ${DST_DIR}

make_mtree()
{
	[ -f /etc/mtree/BSD.root.dist ] && /usr/sbin/mtree -deU -f /etc/mtree/BSD.root.dist -p ${DST_DIR} >/dev/null
	[ -f /etc/mtree/BSD.usr.dist ] && /usr/sbin/mtree -deU -f /etc/mtree/BSD.usr.dist -p ${DST_DIR}/usr >/dev/null
	[ -f /etc/mtree/BSD.var.dist ] && /usr/sbin/mtree -deU -f /etc/mtree/BSD.var.dist -p ${DST_DIR}/var >/dev/null
	[ -f /etc/mtree/BIND.chroot.dist ] && /usr/sbin/mtree -deU -f /etc/mtree/BIND.chroot.dist -p ${DST_DIR}/var/named >/dev/null
	[ -f /etc/mtree/BSD.sendmail.dist ] && /usr/sbin/mtree -deU -f /etc/mtree/BSD.sendmail.dist -p ${DST_DIR} >/dev/null
	[ -f /etc/mtree/BSD.include.dist ] && /usr/sbin/mtree -deU -f /etc/mtree/BSD.include.dist -p ${DST_DIR}/usr/include >/dev/null
	[ -f /etc/mtree/BSD.tests.dist ] && /usr/sbin/mtree -deU -f /etc/mtree/BSD.tests.dist -p ${DST_DIR}/usr/tests >/dev/null
}

# Obtained from https://forums.bsdstore.ru/viewtopic.php?t=9
x="FreeBSD-apm \
FreeBSD-bsnmp \
FreeBSD-clibs \
FreeBSD-hast \
FreeBSD-jail \
FreeBSD-lib \
FreeBSD-libbsdxml \
FreeBSD-libbsm \
FreeBSD-libbz2 \
FreeBSD-libcom_err \
FreeBSD-libcrypt \
FreeBSD-libelf \
FreeBSD-libgeom \
FreeBSD-libgssapi \
FreeBSD-libkvm \
FreeBSD-libldns \
FreeBSD-libmd \
FreeBSD-libopie \
FreeBSD-libsbuf \
FreeBSD-libutil \
FreeBSD-libwrap \
FreeBSD-libxo \
FreeBSD-libypclnt \
FreeBSD-libz \
FreeBSD-rcmds \
FreeBSD-runtime \
FreeBSD-sendmail \
FreeBSD-ssh
"

make_mtree

#for i in $(  pkg query %n | grep ^FreeBSD- ); do
for i in ${x}; do
	pkg create -o ${DST_DIR} $i
	pkg -r ${DST_DIR} add -M -f ${DST_DIR}/*.txz
	rm -f ${DST_DIR}/*.txz
done

[ -d ${DST_DIR}/boot/kernel ] && rm -rf ${DST_DIR}/boot/kernel

cp -a /boot/kernel ${DST_DIR}/boot
cp -a /boot/loader.conf ${DST_DIR}/boot

[ -d ${DST_DIR}/etc ] && rm -rf ${DST_DIR}/etc
cp -a /etc ${DST_DIR}
