#!/bin/bash

#apt update -y
#apt install -y docker.io
#systemctl enable docker.service
systemctl docker start || true
/kubernetes/install_scripts/install_binaries.sh

: ${INSTALL_PATH:=$MOUNT_PATH/kubernetes/install_scripts_secure}

source $INSTALL_PATH/../config
. /kubernetes/tools.subr
. /kubernetes/time.subr
. /kubernetes/ansiicolor.subr

if [ $ENABLE_DEBUG == 'true' ]
then
 [[ "TRACE" ]] && set -x
fi

case "${INIT_ROLE}" in
	worker)
		timeout 30 rsync -avz -e "ssh -oVerifyHostKeyDNS=yes -oStrictHostKeyChecking=no -oPasswordAuthentication=no" ${VIP}:/export/kubecertificate/ /export/kubecertificate/
		timeout 30 rsync -avz -e "ssh -oVerifyHostKeyDNS=yes -oStrictHostKeyChecking=no -oPasswordAuthentication=no" ${VIP}:/export/kubeconfig /export/kubeconfig

		# дожидаемся /var/lib/kubelet/kubeconfig
		max=0
		while [ ${max} -lt 300 ]; do
			wait_msg=
			[ ! -r /export/kubeconfig ] && wait_msg="no such /var/lib/kubelet/kubeconfig, waiting ${max}/300..."
			if [ -z "${wait_msg}" ]; then
				max=1000
			else
				max=$(( max + 1 ))
				echo "${wait_msg}"
				sleep 1
			fi
		done

		if [ ! -r /export/kubeconfig ]; then
			echo "no such /export/kubeconfig"
			exit 1
		fi

		[ ! -d /var/lib/kubelet ] && mkdir -p /var/lib/kubelet
		cp -a /export/kubeconfig /var/lib/kubelet/kubeconfig
		;;
esac

st_time=$( ${DATE_CMD} +%s )
if [ -r $INSTALL_PATH/install_kubelet-${K8S_VER}.sh ]; then
	echo "kubelet for ${K8S_VER}"
	/bin/bash $INSTALL_PATH/install_kubelet-${K8S_VER}.sh worker
	ret=$?
else
	echo "kubelet for ${K8S_VER}"
	/bin/bash $INSTALL_PATH/install_kubelet.sh worker
	ret=$?
fi
end_time=$( ${DATE_CMD} +%s )
diff_time=$(( end_time - st_time ))
diff_time=$( displaytime ${diff_time} )
${ECHO} "${N1_COLOR}${MY_APP}: install kubelet done ${N2_COLOR}in ${diff_time}${N0_COLOR}"

systemctl stop kubelet || true
systemctl start kubelet || true

st_time=$( ${DATE_CMD} +%s )
/bin/bash $INSTALL_PATH/install_kube_proxy.sh
end_time=$( ${DATE_CMD} +%s )
diff_time=$(( end_time - st_time ))
diff_time=$( displaytime ${diff_time} )
${ECHO} "${N1_COLOR}${MY_APP}: install kube_proxy done ${N2_COLOR}in ${diff_time}${N0_COLOR}"

st_time=$( ${DATE_CMD} +%s )
/bin/bash $INSTALL_PATH/install_flannel.sh
end_time=$( ${DATE_CMD} +%s )
diff_time=$(( end_time - st_time ))
diff_time=$( displaytime ${diff_time} )
${ECHO} "${N1_COLOR}${MY_APP}: install_flannel done ${N2_COLOR}in ${diff_time}${N0_COLOR}"

MY_SHORT_HOSTNAME=$( hostname -s )

case "${INIT_ROLE}" in
	worker)
		systemctl stop kubelet || true
		sleep 1
		systemctl start kubelet || true
		[ ! -d /export/rpc ] && mkdir -p /export/rpc
		cat > /export/rpc/task.$$ << EOF
#!/bin/sh
kubectl get nodes ${MY_SHORT_HOSTNAME}
ret=\$?
[ \${ret} -ne 0 ] && exit \${ret}
kubectl label node ${MY_SHORT_HOSTNAME} node-role.kubernetes.io/worker=
ret=\$?
exit \${ret}
EOF
		;;
esac
