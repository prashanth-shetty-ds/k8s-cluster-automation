#!/bin/bash
set -euxo pipefail
export DEBIAN_FRONTEND=noninteractive

echo "[INFO] Starting Kubernetes master bootstrap"

# HARD stop if kubeadm already ran
if [ -f /etc/kubernetes/admin.conf ]; then
  echo "[INFO] Master already initialized"
else
  echo "[INFO] Running kubeadm init"

  kubeadm init \
    --pod-network-cidr=10.244.0.0/16 \
    --cri-socket=unix:///run/containerd/containerd.sock
fi

# VALIDATE kubeadm success
if [ ! -f /etc/kubernetes/admin.conf ]; then
  echo "[ERROR] kubeadm init failed — admin.conf missing"
  exit 1
fi

echo "[INFO] kubeadm init successful"

# Configure kubeconfig for kubeadmin
mkdir -p /home/kubeadmin/.kube
cp /etc/kubernetes/admin.conf /home/kubeadmin/.kube/config
chown kubeadmin:kubeadmin /home/kubeadmin/.kube/config

# Install Flannel
echo "[INFO] Installing Flannel CNI"
sudo -u kubeadmin kubectl apply -f \
https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

# Generate join command (EXPLICIT + VERIFIED)
echo "[INFO] Generating join command"
kubeadm token create --print-join-command \
  > /etc/kubernetes/join-command.sh

chmod 600 /etc/kubernetes/join-command.sh

# FINAL validation
if [ ! -s /etc/kubernetes/join-command.sh ]; then
  echo "[ERROR] Join command file is empty or missing"
  exit 1
fi

echo "[SUCCESS] Master bootstrap completed"
