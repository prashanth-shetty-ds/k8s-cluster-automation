# 🚀 Kubernetes Cluster Automation on Oracle VirtualBox

## Overview

This repository provides a fully automated workflow to provision a **multi-node Kubernetes cluster** on **Oracle VirtualBox** using **kubeadm**, with **Flannel CNI**, and bootstraps **ArgoCD** for downstream GitOps application deployment.

This repo is intentionally scoped to **cluster lifecycle only**.

All application deployments (monitoring, gateways, workloads, etc.) are handled in a **separate GitOps repository** using ArgoCD.

---

## 🎯 Goals

- Automate Kubernetes cluster creation on VirtualBox VMs
- Eliminate manual SSH and ad-hoc kubectl operations
- Provide repeatable, idempotent cluster bootstrap
- Prepare the cluster for GitOps via ArgoCD
- Separate infrastructure and application concerns

---

## 🧱 Architecture

            ┌──────────────────────────────┐
            │     Oracle VirtualBox VMs    │
            │                              │
            │   master-0     worker-0      │
            │                worker-1      │
            └───────────────┬──────────────┘
                            │
                            ▼
                      kubeadm + Flannel
                            │
                            ▼
                           ArgoCD
                            │
                            ▼
                Application GitOps Repository


---

## 📦 What This Repo Does

This repository automates:

- Kubernetes installation via kubeadm
- containerd runtime configuration
- Kernel networking prerequisites
- Flannel CNI setup
- Worker node join
- ArgoCD installation and exposure

It does NOT deploy applications.

Applications are managed by a separate repository:


---

## 🖥️ Cluster Layout

| Node      | IP              | Role          |
|-----------|-----------------|---------------|
| master-0 | 192.168.29.150 | Control Plane |
| worker-0 | 192.168.29.161 | Worker        |
| worker-1 | 192.168.29.162 | Worker        |

Each VM has:

- 4 vCPUs
- 4GB RAM
- 30GB disk
- Dual NIC (Bridged + NAT)

---

## 🛠 Prerequisites

### Host Machine

- Oracle VirtualBox installed
- Ubuntu VMs created
- SSH access enabled
- Internet connectivity

### Bastion / Runner Host

- Linux system
- Self-hosted GitHub Actions runner
- kubectl installed
- kubeconfig available at:


---

## 📂 Repository Structure

``` 
k8s-cluster-automation/
├── README.md
├── inventory
│   └── hosts.env
├── manifests
│   ├── flannel.yaml
│   ├── ingress-nginx.yaml
│   └── monitoring
│       ├── alertmanager.yaml
│       ├── grafana.yaml
│       └── prometheus.yaml
└── scripts
    ├── common.sh
    ├── master.sh
    ├── node-role.sh
    ├── observability.sh
    └── worker.sh
```

---

## ⚙️ Workflow Overview

Cluster provisioning is triggered via GitHub Actions:

``` Actions → Kubernetes Bootstrap → Run workflow ```


The workflow performs:
1. Common prerequisites on all nodes
2. kubeadm init on master
3. Flannel CNI installation
4. Worker join
5. ArgoCD installation

No manual SSH is required after initial VM setup.

---

## 🚦 Kernel Networking Requirements

Each node loads:

- overlay
- br_netfilter

And applies:

``` 
net.bridge.bridge-nf-call-iptables=1
net.ipv4.ip_forward=1 
```


This is required for Flannel networking.

---

## 🔐 Security Model

- No passwords in pipelines
- SSH keys only
- kubeconfig used by runner
- ArgoCD handles runtime reconciliation

---

## 🔄 GitOps Strategy

This repository provisions infrastructure only.

Applications are deployed via:

https://github.com/<org>/k8s-app-gitops


ArgoCD continuously reconciles that repository.

This provides:

- Drift correction
- Declarative deployments
- Zero-touch application delivery

---

## 🧠 Design Principles

- Infrastructure as Code
- Immutable cluster bootstrap
- Declarative GitOps for apps
- Separation of concerns
- Minimal manual intervention
- Lab-friendly but production-aligned

---

## ✅ Validation

After bootstrap:

```bash
kubectl get nodes
kubectl get pods -A 
```
### Expected Output

```
All nodes Ready
Flannel running
CoreDNS running
ArgoCD running
```

## Future Enhancements

- cert-manager + HTTPS
- ExternalDNS
- Gateway API
- Node metrics
- Backup automation
- Multi-cluster support

## 📖 Learning Outcomes

This project demonstrates:

- kubeadm lifecycle management
- CNI troubleshooting
- GitHub Actions automation
- GitOps patterns
- Real-world Kubernetes debugging
- Platform engineering fundamentals

# 👤 Maintainer

Prashanth Shetty

Senior SRE / DevOps Engineer










