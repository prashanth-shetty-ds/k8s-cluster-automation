#!/bin/bash
set -e

swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

modprobe overlay
modprobe br_netfilter

cat <<EOF >/etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables=1
net.ipv4.ip_forward=1
net.bridge.bridge-nf-call-ip6tables=1
EOF
sysctl --system

apt-get update
apt-get install -y containerd apt-transport-https curl

containerd config default >/etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd

curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" \
  >/etc/apt/sources.list.d/kubernetes.list

apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl
