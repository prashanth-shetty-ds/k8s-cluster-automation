#!/bin/bash
set -e

kubeadm init \
  --apiserver-advertise-address=192.168.29.150 \
  --pod-network-cidr=10.244.0.0/16

mkdir -p $HOME/.kube
cp /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f manifests/flannel.yaml
kubectl apply -f manifests/ingress-nginx.yaml

kubeadm token create --print-join-command > /tmp/join.sh
