# Phase 5: DevOps CI/CD + Terraform Multi-Environment Architecture

## Project Context
This document defines the **high-level DevOps and Infrastructure architecture** for deploying and operating **Retrieval-Augmented Generation (RAG) applications** in a scalable, secure, and repeatable manner. The design focuses on **CI/CD automation**, **Infrastructure as Code (IaC)** using Terraform, and **multi-environment support (DEV / QA / PROD)**.

The objective is to enable teams to provision new RAG projects quickly with standardized infrastructure, safe deployment pipelines, and strong operational guardrails.

---

## 1. Objectives & Design Principles

### Primary Objectives
- Standardize build, test, and deployment workflows for all RAG services
- Enable safe and fast promotions across DEV → QA → PROD
- Reduce manual infrastructure work for new RAG use-cases
- Enforce security, observability, and cost controls by default

### Design Principles
- **Infrastructure as Code first** – no manual AWS console changes
- **Environment isolation** – blast radius containment
- **Security by default** – least privilege, encryption, private networking
- **Modular & reusable** – shared Terraform modules
- **Automation over configuration** – minimal human intervention
- **Predictable costs** – tier-based scaling and guardrails

---

## 2. CI/CD Architecture for RAG Applications

### CI/CD Goals
- Consistent pipelines for all RAG services
- Automated testing of RAG-specific workflows
- Progressive delivery with rollback support
- Clear promotion path between environments

### Pipeline Technology Stack
- Source Control: GitHub
- CI/CD Engine: GitHub Actions
- Container Registry: Amazon ECR
- Runtime: ECS Fargate (container-based execution)
- Infrastructure Provisioning: Terraform
- Authentication: GitHub OIDC → AWS IAM

---

## 3. Branching & Promotion Model

### Branch Strategy
- `feature/*` → feature development
- `develop` → DEV environment
- `release/*` or version tags → QA environment
- `main` → PROD environment

### Promotion Flow
1. Feature branches are merged into `develop`
2. DEV deploys automatically
3. Release branches promote builds to QA
4. Main branch deploys to PROD with manual approval

This ensures controlled, auditable releases and minimizes production risk.

---

## 4. CI Pipeline Stages (Build & Test)

### Code Quality
- Static code linting
- Formatting checks
- API contract validation

### Automated Testing
**Unit Tests**
- Individual RAG components
- Prompt template validation

**Integration Tests**
- Document ingestion
- Chunking and metadata extraction
- Embedding generation
- Vector store read/write

**RAG-Specific Validation**
- Retrieval relevance tests (top-K stability)
- Embedding dimension checks
- Structured output validation
- Rate-limit and failure handling

### Security Scans
- Static application security testing (SAST)
- Dependency vulnerability scans
- Container image scanning
- Secret leakage detection

### Build & Artifact Management
- Docker image build
- Versioned image tagging
- Push images to ECR

---

## 5. CD Pipeline Stages (Deploy)

### Environment-Aware Deployments
- DEV: fully automated
- QA: automated with release controls
- PROD: manual approval + guarded rollout

### Deployment Strategies
- Blue-green deployments
- Canary traffic shifting
- Health-based rollback triggers

### Post-Deployment Validation
- Smoke tests
- Health endpoint checks
- Latency and error-rate thresholds

---

## 6. Terraform Infrastructure Architecture

### Goals
- Single reusable infrastructure codebase
- Parameterized per environment and project
- Consistent networking, security, and monitoring

### Module Structure

#### network
- VPC
- Public and private subnets
- Route tables and NAT
- Security groups

#### compute
- ECS services
- Task definitions
- Application Load Balancer
- Auto-scaling policies

#### data
- S3 buckets (documents, logs)
- Vector database backend
- Secrets Manager

#### observability
- CloudWatch log groups
- Metrics and alarms
- Dashboards

#### rag_app (opinionated stack)
- Combines compute, data, IAM, and networking
- Abstracts RAG application deployment

---

## 7. Terraform State & Governance

### Remote State
- Centralized S3 state storage
- DynamoDB locking
- Environment-specific state files

### Tagging Standards
- Environment
- Project
- Owner
- Cost Center
- Data Classification

### Security Defaults
- Private subnets for compute
- TLS for all public endpoints
- Encryption at rest and in transit
- Least-privilege IAM roles

---

## 8. Use-Case–Based Infrastructure Provisioning

### Project Configuration Model
Each RAG use-case is defined using a structured configuration file containing:
- Project name
- Environment
- RAG tier (basic / advanced)
- Traffic profile
- Vector store selection
- Model provider
- Region and domain

### Project Generator Workflow
- Reads project configuration
- Generates Terraform variable files
- Instantiates required modules
- Updates CI/CD pipelines automatically

### Lifecycle Commands
- Create project infrastructure
- Update existing infrastructure
- Destroy sandbox environments

---

## 9. Guardrails & Compliance

### Security Guardrails
- Mandatory logging
- Encrypted storage
- No public data stores
- WAF enforced in production

### Cost Controls
- Tier-based resource limits
- Quota checks before provisioning
- Warnings on high-cost configurations

---

## 10. Multi-Environment Model

### DEV
- Small scale
- Debug logging
- Fully automated deployments

### QA
- Production-like topology
- Test data seeding
- Performance and integration testing

### PROD
- Multi-AZ
- Auto-scaling
- Strict IAM and security policies
- Manual approvals and rollback plans

---

## 11. Pipeline & Terraform Integration

### Infrastructure Changes
- Terraform formatting and validation on PRs
- Plan generation and review
- Apply only on approved branches

### Application Changes
- Image built once
- Promoted across environments
- No rebuilds in production

---

## 12. Expected Outcomes

- Faster onboarding of new RAG projects
- Predictable and repeatable deployments
- Reduced operational risk
- Strong security and compliance posture
- Clear ownership and cost visibility

---

## 13. Future Enhancements
- Policy-as-Code enforcement
- Automated cost anomaly detection
- Multi-region failover
- Advanced RAG performance analytics

---

**End of Document**