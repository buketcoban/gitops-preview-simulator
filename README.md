# GitOps Preview Environment Simulator

A local **GitOps-style preview environment simulator** that creates **branch-isolated Kubernetes preview environments**, validates deployments with smoke tests, stores artifacts in **S3-compatible local storage**, and supports cleanup and TTL-based lifecycle management.

---

## Overview

This project simulates a modern platform engineering workflow for **ephemeral preview environments**.

For each feature branch, the system can:

- create a dedicated Kubernetes namespace
- deploy the application with branch-specific metadata
- expose health and metadata endpoints
- run smoke tests against the deployed preview
- upload test reports as artifacts to S3-compatible local storage
- clean up the preview environment manually or automatically
- apply TTL-based cleanup logic to avoid stale environments

The project is designed to run **locally**, using:

- Docker Desktop
- Kubernetes
- Terraform
- AWS-compatible local service emulation
- Bash automation scripts
- GitHub Actions for CI simulation

---

## Architecture Diagram
![alt text](diagram.png)

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

## Project Goals

The main purpose of this project is to simulate how real platform teams handle **temporary branch-based environments** before production release.

### Why this project?

In real systems, each feature branch may need its own isolated environment for:

- validation
- testing
- debugging
- stakeholder preview
- safer release workflows

This project demonstrates that logic locally, with infrastructure automation and lifecycle controls.

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
└── README.md
```
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

## Phase-by-Phase Implementation

## Phase 1 — Local Platform Bootstrap

The first phase focused on preparing the local infrastructure foundation.

### What was done

- verified existing tools:
  - Docker
  - Terraform
  - AWS CLI
  - Git
  - Python
- enabled Kubernetes in Docker Desktop
- verified cluster availability using:
  - current context
  - node status
  - system pods
- created and deleted a test namespace to validate namespace lifecycle
- started the AWS-compatible local service
- identified the local endpoint at `localhost:4566`
- verified CLI communication with the emulated endpoint
- created a test S3 bucket
- created the Terraform directory structure
- initialized the full project directory layout

### Outcome

A working local platform was prepared for:

- container builds
- Kubernetes deployments
- local S3-style artifact storage
- infrastructure-as-code setup

---

## Phase 2 — Application Scaffold and Dockerization

This phase introduced the application that would later be deployed into preview environments.

### What was done

- created a Python web application
- added:
  - `/health`
  - `/metadata`
- created `requirements.txt`
- created a `Dockerfile`
- exposed the application using `uvicorn`
- built the Docker image
- ran the container locally
- validated endpoints with `curl`

### Outcome

A small branch-aware application was ready to be packaged and deployed.

---

## Phase 3 — Single Kubernetes Deployment

This phase focused on deploying the app into Kubernetes for the first time.

### What was done

- created a Kubernetes namespace
- added Kubernetes base manifests
- created:
  - `deployment.yaml`
  - `service.yaml`
- applied manifests with `kubectl apply`
- checked pod state
- used `port-forward` to access the service locally
- validated the deployment using `curl`

### Outcome

The application successfully ran inside Kubernetes.

---

## Phase 4 — Branch-Based Ephemeral Preview Environments

This is the core phase of the project.

### Goal

Instead of a single static namespace, each branch gets its own isolated preview namespace.

### Example

- `feature/login-fix` → `preview-feature-login-fix`
- `feature/ui-update` → `preview-feature-ui-update`

### What was done

- created `sanitize_branch.sh`
- tested branch name normalization
- created `deploy_preview.sh`
- rebuilt the app image
- deployed the first preview environment
- verified:
  - namespaces
  - pods
  - services
- used `port-forward`
- validated metadata response
- deployed a second branch preview
- repeated verification

### Outcome

The same app could now run in multiple isolated branch-based preview environments.
## Phase 5 — Terraform-Based Local Infrastructure

This phase moved local storage infrastructure into Terraform.

### What was done

- created `provider.tf`
  - configured local AWS-compatible endpoint
  - skipped unnecessary account and metadata validation
  - pointed S3 operations to `localhost:4566`
- created `main.tf`
- created `outputs.tf`
- ran:
  - `terraform init`
  - `terraform plan`
  - `terraform apply -auto-approve`
- validated resources using AWS CLI
- checked Terraform state
- tested actual upload behavior

### Buckets

- `preview_artifacts`
  - stores build outputs, reports, deployment-related files
- `preview_logs`
  - intended for logs from preview environments and application-level logging

### Outcome

S3-style local infrastructure became reproducible and managed as code.

---

## Phase 6 — Smoke Test and Artifact Pipeline

This phase introduced automated validation and artifact generation.

### What was done

- created `run_smoke_test.sh`

### Script responsibilities

- accepts a namespace
- accepts a local port
- creates a temp directory
- prepares metadata and report file paths
- opens a `port-forward` to the preview service
- tracks the process ID
- cleans up the process and temp directory on exit
- calls `/health`
- calls `/metadata`
- extracts:
  - branch
  - commit
  - environment
- generates a JSON smoke test report
- copies the report to the working directory
- prints the report
- tested the script against a deployed preview namespace
- read the generated report
- created `upload_artifact.sh`
- uploaded the smoke test report into the `preview_artifacts` bucket
- verified the artifact in S3-compatible storage

### Outcome

Preview environments were no longer only deployed — they were also validated and recorded.

---

## Phase 7 — Cleanup Automation

This phase added lifecycle termination logic.

### What was done

- created `cleanup_preview.sh`
  - deletes the target preview namespace
- tested cleanup
- verified namespace removal
- created `cleanup_with_report.sh`
  - uploads a cleanup report to S3
  - then deletes the namespace
- tested cleanup reporting
- created `emit_cleanup_event.sh`
  - emits a small event payload
  - simulates event-driven cleanup intent

### Why event-driven cleanup?

The goal was to reflect real deployment lifecycle thinking:

- branch closes
- event is emitted
- cleanup flow is triggered
- preview environment is removed

### Outcome

The project now covered both deployment and environment teardown.
## Phase 8 — TTL-Based Scheduled Cleanup

This phase focused on automatic stale environment removal.

### What was done

- updated `deploy_preview.sh`
- added namespace annotations:
  - creation timestamp
  - TTL value
- created `ttl_cleanup.sh`

### TTL cleanup logic

The script:

- scans preview namespaces
- reads TTL-related annotations
- compares current time vs creation time
- identifies expired preview environments
- uploads a TTL cleanup report to S3
- deletes expired namespaces

### Outcome

Preview environments gained automatic lifecycle expiration logic, reducing stale environment buildup.

---

## Phase 9 — GitHub Integration and CI

This phase connected the repository to GitHub and added workflow automation.

### What was done

- initialized the Git repository
- configured `.gitignore`
- handled Terraform local file exclusions
- pushed the project to GitHub
- created GitHub Actions workflows
- validated workflow execution

### Workflows

- `preview-ci.yml`
  - validates branch-based CI flow
- `preview-cleanup.yml`
  - represents cleanup lifecycle workflow intent

### Important note

When pushing workflow files using a Personal Access Token, the token must include the correct permissions for workflow updates.

### Outcome

The project now included repository-level CI workflow integration.

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

## Example Preview Lifecycle

### Deploy

```bash
./scripts/deploy_preview.sh feature/login-fix abc1234
```bash
./scripts/run_smoke_test.sh preview-feature-login-fix 8001
```
```bash
./scripts/upload_artifact.sh preview-feature-login-fix smoke-test-report.json
```

```bash
./scripts/upload_artifact.sh preview-feature-login-fix smoke-test-report.json
```

```bash
./scripts/cleanup_preview.sh preview-feature-login-fix
```

```bash
./scripts/ttl_cleanup.sh
```

```json
{
  "app": "preview-demo",
  "branch": "feature/login-fix",
  "commit": "abc1234",
  "environment": "preview-feature-login-fix",
  "deployed_at": "2026-04-10T12:00:00Z"
}
```
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