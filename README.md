# GitOps Preview Environment Simulator

A local **GitOps-style preview environment simulator** that creates **branch-isolated Kubernetes preview environments**, validates deployments with smoke tests, stores artifacts in **S3-compatible local storage**, and supports cleanup and TTL-based lifecycle management.

---

## Overview

This project simulates a modern platform engineering workflow for **ephemeral preview environments**.

Instead of testing every change in one shared environment, each feature branch gets its own temporary and isolated preview space. The application is deployed into a branch-specific Kubernetes namespace, validated with smoke tests, and its reports are uploaded to S3-compatible local storage. When the environment is no longer needed, it can be cleaned up manually or removed automatically through TTL-based rules.

The project is designed to run **locally**, using:

- Docker Desktop
- Kubernetes
- Terraform
- AWS-compatible local service emulation
- Bash automation scripts
- GitHub Actions for CI simulation

---

## Architecture Diagram

![GitOps Preview Environment Simulator Architecture](diagram.png)

*End-to-end flow of the GitOps-style preview environment simulator, including branch-based preview namespaces, smoke testing, artifact storage, and cleanup lifecycle.*

---

## Key Features

- branch-based preview namespaces for isolated testing
- FastAPI application with `/health` and `/metadata` endpoints
- Docker-based packaging and local container execution
- Kubernetes deployment and service management
- smoke test automation with JSON report generation
- S3-compatible artifact storage for reports and logs
- Terraform-based local infrastructure provisioning
- manual cleanup and cleanup reporting
- TTL-based automatic cleanup for stale preview environments
- GitHub Actions integration for CI workflow simulation

---

## Tech Stack

- Python / FastAPI
- Docker
- Kubernetes (Docker Desktop Kubernetes)
- Terraform
- AWS CLI
- S3-compatible local endpoint
- Bash
- GitHub Actions

---

## Problem Statement

In a shared development workflow, testing multiple feature branches in the same environment creates confusion and risk. One developer’s changes can affect another developer’s tests, and it becomes difficult to know exactly which branch is running in the current environment.

This project was built to address that problem by simulating a workflow where:

- each feature branch gets its own isolated environment
- the deployed version is clearly identifiable
- validation happens automatically after deployment
- test outputs are stored as artifacts
- stale environments can be removed safely

---

## Why This Approach

This project uses a **GitOps-style preview environment model** because it reflects how modern teams handle temporary branch-based testing environments.

This approach was chosen because it makes it possible to:

- isolate each feature branch in its own Kubernetes namespace
- keep preview environments reproducible and easy to manage
- add validation and artifact generation directly to the deployment flow
- support cleanup and expiration logic as part of the environment lifecycle
- simulate real platform engineering practices locally instead of only showing a CI workflow

Rather than building only a GitHub-based automation demo, this project combines:

- Kubernetes for isolated preview environments
- Terraform for infrastructure provisioning
- S3-compatible local storage for reports and artifacts
- Bash scripts for deployment and lifecycle automation
- GitHub Actions for CI workflow integration

---

## Architecture

### Core Components

- **Python Web App**
  - simple FastAPI application
  - exposes `/health` and `/metadata`

- **Docker**
  - packages the app into a container image

- **Kubernetes**
  - runs preview environments in isolated namespaces

- **Terraform**
  - provisions local S3-style infrastructure

- **AWS-compatible Local Endpoint**
  - emulates S3-compatible storage on `localhost:4566`

- **Automation Scripts**
  - deploy previews
  - sanitize branch names
  - run smoke tests
  - upload artifacts
  - clean up preview environments
  - perform TTL-based cleanup

- **GitHub Actions**
  - validates workflow integration
  - simulates CI behavior for preview lifecycle

---

## How It Works

### High-level flow

1. A branch name is sanitized
2. A dedicated namespace is created
3. The app is deployed into that namespace
4. Metadata is exposed through `/metadata`
5. Smoke tests validate the deployment
6. Reports are uploaded to S3-compatible storage
7. Cleanup can be triggered manually
8. TTL cleanup can remove expired environments automatically
9. CI workflows validate repository-level automation

---

## Repository Structure

```text
gitops-preview-simulator/
├── .github/
│   └── workflows/
│       ├── preview-ci.yml
│       └── preview-cleanup.yml
├── app/
│   ├── Dockerfile
│   ├── main.py
│   └── requirements.txt
├── infra/
│   └── terraform/
│       ├── main.tf
│       ├── outputs.tf
│       ├── provider.tf
│       └── variables.tf
├── k8s/
│   └── base/
│       ├── deployment.yaml
│       └── service.yaml
├── scripts/
│   ├── aws-local-env.sh
│   ├── cleanup_preview.sh
│   ├── cleanup_with_report.sh
│   ├── deploy_preview.sh
│   ├── emit_cleanup_event.sh
│   ├── run_smoke_test.sh
│   ├── sanitize_branch.sh
│   ├── ttl_cleanup.sh
│   └── upload_artifact.sh
├── .gitignore
├── LICENSE
└── README.md
```

---

## Example Commands

### Deploy a preview environment

```bash
./scripts/deploy_preview.sh feature/login-fix abc1234
```

### Run smoke tests

```bash
./scripts/run_smoke_test.sh preview-feature-login-fix 8001
```

### Upload smoke test artifact

```bash
./scripts/upload_artifact.sh preview-feature-login-fix smoke-test-report.json
```

### Clean up a preview environment

```bash
./scripts/cleanup_preview.sh preview-feature-login-fix
```

### Run TTL cleanup

```bash
./scripts/ttl_cleanup.sh
```

---

## Metadata Example

Example `/metadata` response:

```json
{
  "app": "preview-demo",
  "branch": "feature/login-fix",
  "commit": "abc1234",
  "environment": "preview-feature-login-fix",
  "deployed_at": "2026-04-10T12:00:00Z"
}
```

---

## Artifact Storage

The project uses S3-compatible local storage to keep deployment-related outputs.

### Buckets

- `preview_artifacts`
  - stores smoke test reports, deployment-related files, and cleanup reports
- `preview_logs`
  - intended for logs from preview environments and application-level logging

This separation makes it easier to distinguish validation artifacts from runtime log data.

---

## CI Workflows

The repository includes GitHub Actions workflows to simulate the CI side of the preview environment lifecycle.

### Included workflows

- `preview-ci.yml`
  - validates branch-based CI flow
  - builds the Docker image
  - generates preview metadata artifact

- `preview-cleanup.yml`
  - represents cleanup lifecycle workflow intent
  - models cleanup trigger behavior when a pull request is closed

### Important note

When pushing workflow files using a Personal Access Token, the token must include the correct permissions for workflow updates.

---

## Key Engineering Concepts Demonstrated

- branch-based preview environments
- namespace isolation
- ephemeral environment lifecycle
- Docker image packaging
- Kubernetes deployments and services
- S3-compatible artifact storage
- Terraform-based infrastructure provisioning
- smoke test automation
- cleanup workflow design
- TTL-based stale environment cleanup
- CI workflow integration
- local simulation of cloud-native platform behavior

---

## Limitations

This project is a local simulation, not a full production platform.

### Current limitations

- uses local AWS-compatible service emulation instead of real AWS
- GitHub Actions does not directly deploy into the local cluster
- event-driven cleanup is simulated rather than fully integrated with a real event bus
- observability is minimal
- authentication and ingress are simplified

---

## Future Improvements

Possible next steps:

- add Helm packaging
- add self-hosted GitHub runner for local cluster deployment
- integrate real ingress routing for preview URLs
- add centralized logging and metrics
- replace simulated event flow with a real message or event system
- add PR comment automation with preview metadata
- add dashboard UI for active preview environments

---

## Resume / Interview Summary

This project demonstrates the design of a GitOps-style ephemeral preview environment platform running locally on Kubernetes.

It includes:

- branch-based namespace isolation
- automated deployment logic
- smoke test validation
- artifact storage in S3-compatible local infrastructure
- Terraform-managed storage provisioning
- manual and TTL-based cleanup automation
- GitHub Actions integration for CI workflow simulation

---

## Author

Built as a technical portfolio project to simulate modern platform engineering, preview environment lifecycle management, and cloud-native deployment automation in a local environment.