#!/usr/bin/env bash
set -euo pipefail

# Expected runtime variables from Morpheus request/form:
# K8S_VERSION, CLUSTER_NAME, POD_NETWORK_CIDR

: "${K8S_VERSION:?K8S_VERSION is required}"
: "${CLUSTER_NAME:?CLUSTER_NAME is required}"
: "${POD_NETWORK_CIDR:=10.244.0.0/16}"

sudo kubeadm init \
  --kubernetes-version "${K8S_VERSION}" \
  --cluster-name "${CLUSTER_NAME}" \
  --pod-network-cidr "${POD_NETWORK_CIDR}" \
  --upload-certs

sudo mkdir -p /root/.kube
sudo cp /etc/kubernetes/admin.conf /root/.kube/config
sudo chmod 600 /root/.kube/config /etc/kubernetes/admin.conf

# Print join commands for follow-up tasks.
sudo kubeadm token create --print-join-command
sudo kubeadm init phase upload-certs --upload-certs | tail -n1
