#!/bin/bash
set -euxo pipefail

POD_CIDR="10.244.0.0/16"
CRI_SOCKET="unix:///run/containerd/containerd.sock"

echo "[INFO] Entered master.sh"

if [ -f /etc/kubernetes/admin.conf ]; then
  echo "[INFO] Control plane already initialized"
  exit 0
fi

echo "[INFO] Running kubeadm init..."

kubeadm init \
  --pod-network-cidr=${POD_CIDR} \
  --cri-socket=${CRI_SOCKET}

echo "[INFO] kubeadm init completed"

mkdir -p /home/kubeadmin/.kube
cp /etc/kubernetes/admin.conf /home/kubeadmin/.kube/config
chown kubeadmin:kubeadmin /home/kubeadmin/.kube/config

echo "[INFO] Installing Flannel CNI"
sudo -u kubeadmin kubectl apply -f \
  https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

echo "[SUCCESS] Master initialized"
