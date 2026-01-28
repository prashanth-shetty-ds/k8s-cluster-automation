#!/bin/bash
set -e

POD_CIDR="10.244.0.0/16"
CRI_SOCKET="unix:///run/containerd/containerd.sock"

# Prevent re-initialization (idempotency)
if [ -f /etc/kubernetes/admin.conf ]; then
  echo "[INFO] Kubernetes master already initialized. Skipping kubeadm init."
  exit 0
fi

echo "[INFO] Initializing Kubernetes control plane..."

kubeadm init \
  --pod-network-cidr=${POD_CIDR} \
  --cri-socket=${CRI_SOCKET}

echo "[INFO] Configuring kubectl for kubeadmin..."

mkdir -p /home/kubeadmin/.kube
cp /etc/kubernetes/admin.conf /home/kubeadmin/.kube/config
chown kubeadmin:kubeadmin /home/kubeadmin/.kube/config

echo "[INFO] Installing Flannel CNI..."

sudo -u kubeadmin kubectl apply -f \
  https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

echo "[INFO] Generating worker join command..."

kubeadm token create --print-join-command > /tmp/kubeadm_join.sh
chmod +x /tmp/kubeadm_join.sh

echo "[SUCCESS] Master initialization complete."
