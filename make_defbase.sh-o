#!/bin/sh

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

. /etc/rc.conf
workdir="${cbsd_workdir}"

set -e
. ${workdir}/cbsd.conf
. ${workdir}/nc.subr
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

find ${BASE_DIR} \( -type f -or -type l \) -print |while read _p; do
	a=$( echo ${_p}| sed s:${BASE_DIR}::g )
	dir=$( dirname ${a} )
	case "${dir}" in
		/rescue*|/usr/tests*|/compat/*|/sys/*)
			continue
			;;
	esac
	echo $a >> ${tmpfiles}
done

sort ${tmpfiles}
