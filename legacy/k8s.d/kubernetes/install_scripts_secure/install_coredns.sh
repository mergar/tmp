#!/bin/bash

: ${INSTALL_PATH:=$MOUNT_PATH/kubernetes/install_scripts_secure}

source $INSTALL_PATH/../config
if [ $ENABLE_DEBUG == 'true' ]
then
[[ "TRACE" ]] && set -x
fi


sed -i "s/CLUSTER_DNS_IP/${DNS_IP}/g" /kubernetes/kube_service/coredns/coredns.yaml
sed -i "s/CLUSTER_DOMAIN/cluster.local/g" /kubernetes/kube_service/coredns/coredns.yaml
sed -i "s:REVERSE_CIDRS:10.254.0.0/16 100.127.64.0/18:g" /kubernetes/kube_service/coredns/coredns.yaml
sed -i "s:UPSTREAMNAMESERVER:1.1.1.1:g" /kubernetes/kube_service/coredns/coredns.yaml

kubectl create -f /kubernetes/kube_service/coredns/coredns.yaml

exit 0
