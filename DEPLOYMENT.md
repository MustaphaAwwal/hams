# Deployment Guide

## Overview

This document describes the full deployment flow for the HAMS AI Platform, including:

* **Infrastructure provisioning** with Terraform.
* **Application deployments** with Helm (LiveKit, Loki stack, SIP, Agent).
* **Value files** for application configuration.
* **GitHub Actions** workflows for automation.

The platform runs on **AWS EKS (multi-AZ, auto mode)** with separate **Sandbox** and **Live** environments.


## 1. Infrastructure Deployment (Terraform)

Terraform is used to provision and manage:

* **AWS EKS** cluster (multi-AZ, auto mode)
* **Networking** (VPC, subnets, security groups)
* **S3** for  storage
* **AWS ElastiCache (Redis)**
* **Observability stack base infrastructure**
* **IAM roles** (including GitHub Actions OIDC role)

### Steps

1. **Set up Terraform backend** (S3 + DynamoDB):

   ```bash
   cd terraform/global/s3-backend
   terraform init
   terraform apply
   ```

2. **Set up GitHub OIDC IAM Role**:

   ```bash
   cd terraform/global/iam
   terraform init
   terraform apply
   ```

   Note the `github_actions_role_arn` output for GitHub Actions.

3. **Deploy environment-specific infrastructure**:

   ```bash
   cd terraform/environments/<environment> # sandbox or live
   terraform init
   terraform apply
   ```


## 2. Application Deployment (Helm)

Applications are deployed on the EKS cluster using Helm:

Got it — that TURN TLS secret creation should be part of the **LiveKit server deployment section** in your `Deployment.md`.
Here’s the updated **LiveKit** part of the doc with that step included:


### 2.1 LiveKit

* **Source:** Official Helm chart
* **Values file:** `helm/values/livekit-values.yaml`
* **Namespace:** `livekit`

**Before deploying the LiveKit server**, create the TURN TLS secret:

```bash
kubectl create secret tls <SECRET-NAME> \
  --cert <CERT-FILE> \
  --key <KEY-FILE> \
  --namespace livekit
```

If your cert and key are base64-encoded in GitHub secrets, decode them first:

```bash
echo "$TLS_CERT_B64" | base64 -d > tls.crt
echo "$TLS_KEY_B64" | base64 -d > tls.key
kubectl create secret tls livekit-turn-cert \
  --cert tls.crt \
  --key tls.key \
  --namespace livekit
```

Then install/upgrade LiveKit:

```bash
helm upgrade --install livekit-server \
  oci://registry-1.docker.io/livekitcharts/livekit-server \
  --namespace livekit \
  --create-namespace \
  --values helm/values/livekit-values.yaml
```




### 2.2 Observability Stack (Loki & Promtail)

The kube-prometheus-stack (Prometheus, Alertmanager, and related monitoring components) is already installed via EKS managed add-ons and does not need to be deployed manually.
This section covers the additional observability components that are deployed manually — Loki for log aggregation and Promtail for log shipping.

* **Source:** Grafana Helm repo (`loki-simple-scalable`, `promtail`)
* **Values files:**

  * Loki: `helm/values/loki-values.yaml`
  * Promtail: `helm/values/promtail-values.yaml`
* **Namespace:** `observability`

```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

helm upgrade --install loki grafana/loki-simple-scalable \
  --namespace observability \
  --create-namespace \
  --values helm/values/loki-values.yaml

helm upgrade --install promtail grafana/promtail \
  --namespace observability \
  --values helm/values/promtail-values.yaml
```



### 2.3 SIP Service (Local Chart)

* **Source:** `helm/charts/livekit-sip`

```bash
helm upgrade --install livekit-sip ./helm/charts/livekit-sip \
  --namespace livekit \
  --create-namespace 
```

### 2.4 Agent Service (Local Chart)

* **Source:** `helm/charts/livekit-agent`

```bash
helm upgrade --install livekit-agent ./helm/charts/livekit-agent \
  --namespace livekit \
  --create-namespace 
```


## 3. GitHub Actions Automation

Two key GitHub Actions workflows manage deployments:

* **Terraform Infra Deployment**

  * Provisions AWS infrastructure
  * Runs `terraform init` and `terraform apply` in environment directories
  * Uses OIDC authentication to assume the AWS role

* **Helm App Deployment**

  * Deploys or upgrades LiveKit, Loki, SIP, and Agent charts
  * Selectable via workflow inputs (`environment`, `action`, `component`)
  * Uses the `helm/values/*.yaml` files for configuration
  * Installs local charts for SIP and Agent

Example workflow dispatch inputs:

```yaml
inputs:
  environment: sandbox
  action: install
  component: both
```

---

## 4. Deployment Order

When setting up from scratch:

1. **Terraform**:

   * Global backend
   * IAM OIDC role
   * Environment infrastructure
2. **Helm Apps** (via GitHub Actions or manually):

   * LiveKit
   * Observability stack (Loki)
   * SIP Service
   * Agent Service


## 5. Notes

* All sensitive values (certs, keys, AWS creds) are stored as **GitHub Secrets**.
* `gp3` or CSI-backed StorageClasses are recommended for PVCs.
* Observability stack requires EBS CSI driver for persistence.
