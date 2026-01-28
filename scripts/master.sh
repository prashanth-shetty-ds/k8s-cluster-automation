#!/bin/bash
set -euxo pipefail
export DEBIAN_FRONTEND=noninteractive

echo "[INFO] Entering master bootstrap"

if [ -f /etc/kubernetes/admin.conf ]; then
  echo "[INFO] Master already initialized"
  exit 0
fi

kubeadm init \
  --pod-network-cidr=10.244.0.0/16 \
  --cri-socket=unix:///run/containerd/containerd.sock

mkdir -p /home/kubeadmin/.kube
cp /etc/kubernetes/admin.conf /home/kubeadmin/.kube/config
chown kubeadmin:kubeadmin /home/kubeadmin/.kube/config

# Install Flannel
sudo -u kubeadmin kubectl apply -f \
https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

# Generate join command for workers
kkubeadm token create --print-join-command > /etc/kubernetes/join-command.sh
chmod 600 /etc/kubernetes/join-command.sh

echo "[SUCCESS] Master initialized"
