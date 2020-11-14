#!/bin/sh

while getopts "h:p:" opt; do
	case "${opt}" in
		h) hosts="${OPTARG}" ;;
		p) path="${OPTARG}" ;;
	esac
        shift $(($OPTIND - 1))
done

if [ -z "${hosts}" ]; then
	echo "usage: $0 -h \"IP1 IP2 IP3\" -p /nfs"
	exit 1
fi
if [ -z "${path}" ]; then
	echo "usage: $0 - \"IP1 IP2 IP3\" -p /nfs"
	exit 1
fi

# todo: check for ip existance on the host
# todo: check for dir exist (zfs sharenfs)

echo "   * modify /etc/exports..."

cat > /etc/exports <<EOF
${path} -alldirs -maproot=root ${hosts}
V4: / ${hosts}
EOF


for i in mountd; do
	echo "   * restart ${i} service..."
	/usr/sbin/service ${i} restart > /dev/null 2>&1
done

exit 0
