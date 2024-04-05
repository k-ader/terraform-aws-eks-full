#!/bin/bash
set -ex
sed -i '/RES_OPTIONS/s/".*/"rotate single-request"/' /etc/sysconfig/network-scripts/ifcfg-eth0
sed -i '/options /s/.*/options rotate single-request no-inet6/' /etc/resolv.conf
sed -i 's/search .*//g' /etc/resolv.conf
B64_CLUSTER_CA=${cluster_ca}
API_SERVER_URL=${cluster_endpoint}
/etc/eks/bootstrap.sh ${cluster_name} --container-runtime containerd --apiserver-endpoint $API_SERVER_URL --b64-cluster-ca $B64_CLUSTER_CA --dns-cluster-ip "${service_ipv4_cidr}"
