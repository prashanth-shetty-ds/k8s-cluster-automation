#!/bin/bash
set -e

JOIN_CMD=$(ssh kubeadmin@192.168.29.150 "cat /tmp/join.sh")
sudo $JOIN_CMD
