#!/bin/sh

: ${distdir="/usr/local/cbsd"}

# MAIN()
while getopts "v:a:t:s:" opt; do
	case "${opt}" in
		v) orver="${OPTARG}" ;;
		a) orarch="${OPTARG}" ;;
		t) ortargetarch="${OPTARG}" ;;
		s) ORSTABLE="${OPTARG}" ;;
		*) usage ;;
	esac
	shift $(($OPTIND - 1))
done

if [ -z "${workdir}" ]; then
	[ -z "${cbsd_workdir}" ] && . /etc/rc.conf
	[ -z "${cbsd_workdir}" ] && exit 0
	workdir="${cbsd_workdir}"
fi

set -e
. ${distdir}/cbsd.conf
. ${distdir}/tools.subr
. ${distdir}/nc.subr
set +e

export NOCOLOR=1

[ -n "${orver}" ] && ver="${orver}"
[ -n "${orarch}" ] && arch="${orarch}"
[ -n "${ortargetarch}" ] && otargetarch="${ortargetarch}"
[ -n "${ORSTABLE}" ] && STABLE="${ORSTABLE}"

[ -z "${ver}" ] && err 1 "Give me version, e.g: -v 11.0"
[ -z "${stable}" ] && STABLE=0

[ -z "${arch}" ] && arch=$( uname -m )
[ -z "${targetarch}" ] && targetarch=$arch

tmpfiles=$( mktemp )
trap "/bin/rm -f ${tmpfiles}" HUP INT ABRT BUS TERM EXIT

BASE_DIR="/usr/jails/basejail/base_${arch}_${arch}_${ver}"

if [ ! -d "${BASE_DIR}" ]; then
	echo "No $BASE_DIR"
	exit 0
fi

hl_count=0
rm -f base_hl_*.txt

find ${BASE_DIR} \( -type f -or -type l \) -print |while read _p; do
	a=$( echo ${_p}| sed s:${BASE_DIR}::g )
	dir=$( dirname ${a} )

	case "${dir}" in
		/rescue*|/usr/tests*|/compat/*|/sys/*)
			continue
			;;
	esac

	HLINK_CNT=$( /usr/bin/stat -f "%l" ${_p} )

	if [ ${HLINK_CNT} -eq 1 ]; then
		echo $a >> ${tmpfiles}
		continue
	fi

	echo "HL ${hl_count}: ${a}" 1>&2

	inode=$( stat -f "%i" ${_p} )

	[ -r base_hl_${inode}.txt ] && continue

	/usr/bin/find ${BASE_DIR} -samefile ${_p} -print >> base_hl_${inode}.txt

	list=$( cat base_hl_${inode}.txt |while read _a; do
		b=$( echo ${_a}| sed s:${BASE_DIR}::g )
		printf "${b} "
	done )

	echo "% ${list}" >> ${tmpfiles}
	rm -f base_hl_${inode}.txt
	hl_count=$(( hl_count + 1 ))

done

sort -u ${tmpfiles} |sort
