#!/bin/sh

while getopts "h:" opt; do
	case "${opt}" in
		h) bindip="${OPTARG}" ;;
	esac
        shift $(($OPTIND - 1))
done

if [ -z "${bindip}" ]; then
	echo "usage: $0 -h <bindip>"
	exit 1
fi

# todo: check for ip existance on the host

echo "   * modify /etc/rc.conf for service enable..."

/usr/sbin/sysrc -qf /etc/rc.conf \
nfsv4_server_enable="YES" \
nfscbd_enable="YES" \
nfsuserd_enable="YES" \
mountd_enable="YES" \
rpc_lockd_enable="YES" \
nfs_server_enable="YES" \
nfs_server_flags="-u -t -h ${bindip}" \
mountd_flags="-r -S -h ${bindip}" \
rpcbind_flags="-h ${bindip}" \
rpcbind_enable="YES" > /dev/null 2>&1

for i in mountd nfsuserd nfsd rpcbind lockd; do
	echo "   * restart ${i} service..."
	/usr/sbin/service ${i} restart > /dev/null 2>&1
done

exit 0
