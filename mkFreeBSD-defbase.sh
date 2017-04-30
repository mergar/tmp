#!/bin/sh

BASE_DIR="/usr/jails/basejail/base_amd64_amd64_11.0"
#FILES="/usr/local/cbsd/share/FreeBSD-defbase_10.2.txt"
FILES="/x.txt.xz"

DST_DIR="/usr/c"

make_mtree()
{
	[ -f ${BASE_DIR}/etc/mtree/BSD.root.dist ] && /usr/sbin/mtree -deU -f ${BASE_DIR}/etc/mtree/BSD.root.dist -p ${DST_DIR} >/dev/null
	[ -f ${BASE_DIR}/etc/mtree/BSD.usr.dist ] && /usr/sbin/mtree -deU -f ${BASE_DIR}/etc/mtree/BSD.usr.dist -p ${DST_DIR}/usr >/dev/null
	[ -f ${BASE_DIR}/etc/mtree/BSD.var.dist ] && /usr/sbin/mtree -deU -f ${BASE_DIR}/etc/mtree/BSD.var.dist -p ${DST_DIR}/var >/dev/null
	[ -f ${BASE_DIR}/etc/mtree/BIND.chroot.dist ] && /usr/sbin/mtree -deU -f ${BASE_DIR}/etc/mtree/BIND.chroot.dist -p ${DST_DIR}/var/named >/dev/null
	[ -f ${BASE_DIR}/etc/mtree/BSD.sendmail.dist ] && /usr/sbin/mtree -deU -f ${BASE_DIR}/etc/mtree/BSD.sendmail.dist -p ${DST_DIR} >/dev/null
	[ -f ${BASE_DIR}/etc/mtree/BSD.include.dist ] && /usr/sbin/mtree -deU -f ${BASE_DIR}/etc/mtree/BSD.include.dist -p ${DST_DIR}/usr/include >/dev/null
	[ -f ${BASE_DIR}/etc/mtree/BSD.tests.dist ] && /usr/sbin/mtree -deU -f ${BASE_DIR}/etc/mtree/BSD.tests.dist -p ${DST_DIR}/usr/tests >/dev/null
}

make_libmap()
{
	A=$( /usr/bin/mktemp /tmp/libtxt.XXX )
	B=$( /usr/bin/mktemp /tmp/libtxtsort.XXX )
	TRAP="${TRAP} /bin/rm -f ${A} ${B};"
	trap "${TRAP}" HUP INT ABRT BUS TERM EXIT

	/usr/bin/xzcat ${FILES} |while read line; do
		[ -z "${line}" ] && continue
		case ":${line}" in
			:#*)
				continue
				;;
		esac
		/usr/bin/ldd -f "%p\n" ${BASE_DIR}${line} >> $A 2>/dev/null
	done
	/usr/bin/sort -u ${A} > ${B}
	echo "${B}"

}

copy_binlib()
{
	/usr/bin/xzcat ${FILES}| while read line; do
		[ -z "${line}" ] && continue
		case ":${line}" in
			:#*)
				continue
				;;
		esac
		D=$( /usr/sbin/chroot ${BASE_DIR} dirname ${line} )
		/usr/local/bin/rsync -av ${BASE_DIR}${line} ${DST_DIR}${D}
		A=$( /usr/bin/readlink ${BASE_DIR}${line} )
		if [ -n "${A}" -a -f "${D}/${A}" ]; then
			echo "SYM: $A"
			/usr/local/bin/rsync -av -${D}${A} ${DST_DIR}${D}
		fi
	done

	/bin/cat ${B}| while read line; do
		[ -z "${line}" ] && continue
		D=$( /usr/sbin/chroot ${BASE_DIR} dirname ${line} )
		/usr/local/bin/rsync -avzx ${BASE_DIR}${line} ${DST_DIR}${D}
	done

	/bin/rm -f ${A} ${B}
}



prunelist()
{
	[ ! -f "${prunelist}" ] && return 0 # no prune
	[ -z "${1}" ] && return 0 # sanity

	${ECHO} "${MAGENTA}Prune file by list: ${GREEN}${prunelist}${NORMAL}"

	for FILE in $( /bin/cat ${prunelist} ); do
		[ -z "${FILE}" ] && continue
		case ":${FILE}" in
			:#* | :)
				continue
				;;
		esac
		/bin/rm -rf ${1}/${FILE} 2>/dev/null
	done
}

chflags -R noschg ${DST_DIR}
rm -rf ${DST_DIR}
mkdir ${DST_DIR}

make_mtree
make_libmap
copy_binlib
