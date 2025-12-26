# Phase 5 (LLD): CI/CD + Terraform Multi-Environment Design for RAG Platform

> **Purpose:** This Low-Level Design (LLD) document translates the high-level architecture into **implementable repo layouts, Terraform module interfaces, CI/CD workflows, naming standards, IAM boundaries, and operational runbooks**.

---

## 0) Reference Architecture Summary

### Target Runtime (Default)
- **ECS Fargate** for RAG services (API + worker)
- **ALB** for ingress (HTTPS)
- **ECR** for container images
- **S3** for documents / artifacts
- **Vector store** pluggable (OpenSearch / Aurora pgvector / DynamoDB)
- **CloudWatch** logs, metrics, dashboards, alarms
- **Secrets Manager** for credentials and API keys
- **Terraform** for all infrastructure
- **GitHub Actions** for CI/CD (OIDC to assume AWS roles)

---

## 1) Repository & Folder Structure

### 1.1 Monorepo (recommended) layout
```
repo-root/
  apps/
    rag-api/                 # REST API (FastAPI/Flask)
    rag-worker/              # ingestion/embedding jobs
    shared/                  # shared libs, schemas, prompt templates
  infra/
    modules/
      network/
      compute-ecs/
      data/
      observability/
      rag_app/
    envs/
      dev/
        main.tf
        providers.tf
        backend.tf
        terraform.tfvars
      qa/
        ...
      prod/
        ...
  scripts/
    project-generator/       # generates tfvars + workflows from YAML
  .github/
    workflows/
      ci.yml
      deploy-dev.yml
      deploy-qa.yml
      deploy-prod.yml
      infra-plan.yml
      infra-apply.yml
  docs/
    Phase5-HLD.md
    Phase5-LLD.md
```

### 1.2 Naming Standards
- AWS resource prefix: `${org}-${project}-${env}`
- Example: `fmg-claims-assistant-dev`
- Tags (mandatory):
  - `Environment`, `Project`, `Owner`, `CostCenter`, `DataClassification`

---

## 2) Terraform Implementation Details

### 2.1 Terraform version & providers
- Terraform: `>= 1.6`
- AWS Provider: `>= 5.x`
- Recommended provider config: pinned via `required_providers`.

### 2.2 Remote State
- S3 bucket: `org-terraform-state`
- DynamoDB locks: `org-terraform-locks`
- State key convention:
  - `rag/${project}/${env}/terraform.tfstate`

### 2.3 Environment Separation Model
Use **folder-per-environment** with shared modules:
- `infra/envs/dev`
- `infra/envs/qa`
- `infra/envs/prod`

Each env uses:
- its own `backend.tf` key
- env-specific `terraform.tfvars` (scale, subnets, WAF, retention)

---

## 3) Terraform Modules (Interfaces & Contents)

> This section lists each module’s **inputs, outputs, and resources**. Keep modules small and composable.

### 3.1 `modules/network`
**Purpose:** VPC + subnets + routing + NAT + baseline SG.

**Core resources**
- `aws_vpc`
- `aws_subnet` (public/private across 2–3 AZs)
- `aws_internet_gateway`
- `aws_nat_gateway` (per AZ for prod; single for dev)
- `aws_route_table` + associations
- `aws_security_group` baseline

**Key inputs**
- `name_prefix`, `vpc_cidr`
- `az_count`, `public_subnet_cidrs`, `private_subnet_cidrs`
- `enable_nat`, `nat_mode` (`single|per_az`)
- `tags`

**Key outputs**
- `vpc_id`, `public_subnet_ids`, `private_subnet_ids`
- `alb_sg_id`, `ecs_task_sg_id`

---

### 3.2 `modules/compute-ecs`
**Purpose:** ECS Cluster + Services + Task Definitions + ALB + Autoscaling.

**Core resources**
- ECS: `aws_ecs_cluster`, `aws_ecs_service`, `aws_ecs_task_definition`
- ALB: `aws_lb`, `aws_lb_target_group`, `aws_lb_listener`
- IAM: task execution role, task role, policies
- Autoscaling: `aws_appautoscaling_target`, `aws_appautoscaling_policy`
- Logs: `aws_cloudwatch_log_group`

**Service split (recommended)**
- `rag-api` (HTTP, behind ALB)
- `rag-worker` (no ingress; triggered by SQS/EventBridge or scheduled)

**Key inputs**
- `cluster_name`, `name_prefix`
- `subnet_ids` (private)
- `alb_subnet_ids` (public)
- `container_image_api`, `container_image_worker`
- `cpu`, `memory`, `desired_count`
- `min_capacity`, `max_capacity`
- `env_vars`, `secrets` (Secrets Manager ARNs)
- `certificate_arn`, `domain_name`
- `tags`

**Key outputs**
- `alb_dns_name`, `alb_arn`, `listener_arn`
- `ecs_cluster_arn`, `api_service_name`, `worker_service_name`

---

### 3.3 `modules/data`
**Purpose:** Data layer (S3 + vector store + secrets).

**Core resources**
- S3: docs bucket, ingestion bucket, backup bucket (optional)
- KMS keys (optional per env)
- Secrets Manager: API keys, DB creds
- Vector store (select one):
  - OpenSearch domain
  - Aurora PostgreSQL (pgvector)
  - DynamoDB (metadata + pointers)

**Key inputs**
- `name_prefix`
- `vector_store_type` (`opensearch|aurora_pgvector|dynamodb`)
- `enable_versioning`, `lifecycle_rules`
- `kms_key_arn` (or module-managed)
- `tags`

**Key outputs**
- `docs_bucket_name`, `ingest_bucket_name`
- `vector_endpoint`, `vector_secret_arn`
- `secrets_arns`

---

### 3.4 `modules/observability`
**Purpose:** Logs, metrics, alarms, dashboards.

**Core resources**
- CloudWatch log groups (API + worker)
- CloudWatch alarms:
  - ALB 5xx
  - ECS CPU/Memory > threshold
  - Target response time
  - Healthy host count
- Dashboard widgets:
  - requests/latency/errors
  - ECS task count
  - vector store latency

**Key inputs**
- `name_prefix`, `log_retention_days`
- `alarm_email` (SNS subscription)
- `tags`

**Key outputs**
- `dashboard_name`, `alarm_arns`, `log_group_names`

---

### 3.5 `modules/rag_app` (composition module)
**Purpose:** Opinionated wrapper that composes network + compute + data + observability.

**Inputs**
- `project_name`, `environment`, `region`, `domain_name`
- `rag_tier` (`basic|advanced`)
- `traffic_profile` (`low|medium|high`)
- `vector_store_type`, `model_provider` (`bedrock|openai`)
- `image_tag_api`, `image_tag_worker`

**Outputs**
- `endpoint_url`, `alb_dns_name`
- `docs_bucket_name`
- `log_groups`, `dashboard_name`

---

## 4) Environment Profiles (Concrete Defaults)

### 4.1 DEV defaults
- `desired_count_api=1`, `min=1`, `max=2`
- smaller CPU/memory
- debug logging ON
- shorter log retention (e.g., 7–14 days)

### 4.2 QA defaults
- `desired_count_api=1–2`, `min=1`, `max=3`
- prod-like topology, downsized
- integration + load tests enabled
- log retention 30 days

### 4.3 PROD defaults
- `desired_count_api=2+`, `min=2`, `max=10+`
- multi-AZ NAT (per AZ)
- WAF ON
- log retention 90–180 days
- strict approvals + canary/blue-green

---

## 5) CI/CD Workflows (GitHub Actions)

### 5.1 AWS Authentication (OIDC)
**Pattern:** GitHub Action assumes a role per environment.
- Role naming: `gha-rag-deploy-dev`, `gha-rag-deploy-qa`, `gha-rag-deploy-prod`
- Permissions scoped to:
  - ECR push/pull
  - ECS update service
  - CloudWatch logs read
  - Terraform state bucket read/write (for infra jobs)

### 5.2 Workflow: `ci.yml` (PR + push)
**Triggers**
- PRs to `develop`, `release/*`, `main`

**Jobs**
- lint
- unit tests
- integration tests (optional on PR, mandatory on release)
- build docker images (on merge)
- security scans (SAST/deps/container)

**Artifacts**
- test reports
- image tag metadata (`image.json`)

### 5.3 Workflow: `deploy-dev.yml`
**Trigger:** push to `develop`
**Steps**
1. build + push image to ECR
2. update ECS service task definition with new image
3. wait for service stability
4. smoke test `/health` + `/ready`

### 5.4 Workflow: `deploy-qa.yml`
**Trigger:** push to `release/*` or tag
**Steps**
- promote existing image digest (no rebuild)
- run integration tests against QA endpoint
- run minimal load test (k6/locust) optional

### 5.5 Workflow: `deploy-prod.yml`
**Trigger:** push to `main`
**Controls**
- requires GitHub Environment approval (PROD)
- deploy strategy:
  - blue/green OR canary
- rollback:
  - on failed smoke tests
  - on CloudWatch alarm breach

---

## 6) Terraform in Pipelines

### 6.1 Infra PR checks
- `terraform fmt -check`
- `terraform validate`
- `tflint`
- `checkov` (or similar)
- `terraform plan` (posted to PR)

### 6.2 Apply rules
- DEV apply: automatic on merge (optional)
- QA apply: on release branch
- PROD apply: manual approval required

---

## 7) RAG Application Runtime Contracts

### 7.1 Required endpoints
- `GET /health` → basic liveness
- `GET /ready` → dependency readiness (vector store reachable, model provider configured)

### 7.2 Required environment variables
- `ENV` (`dev|qa|prod`)
- `LOG_LEVEL`
- `VECTOR_STORE_TYPE`
- `MODEL_PROVIDER`
- `S3_DOCS_BUCKET`

### 7.3 Secrets (Secrets Manager)
- `OPENAI_API_KEY` (if model_provider=openai)
- `BEDROCK_ROLE_ARN` or relevant (if bedrock)
- `VECTOR_DB_PASSWORD` (if aurora)

---

## 8) Observability (Implementation)

### 8.1 Logging
- Structured JSON logs
- correlation id header propagation
- log groups:
  - `/rag/${project}/${env}/api`
  - `/rag/${project}/${env}/worker`

### 8.2 Metrics (minimum)
- Request count, latency p50/p95/p99
- Token usage (if available)
- Retrieval latency
- Vector store error rates

### 8.3 Alarms (minimum)
- ALB `HTTPCode_Target_5XX_Count` high
- Target response time high
- ECS CPU/Memory sustained high
- Unhealthy host count > 0

---

## 9) Security Controls (LLD)

### 9.1 Network
- ECS tasks in private subnets
- ALB is only public entry
- Security group rules:
  - ALB inbound: 443 from internet (or CIDR allowlist)
  - ECS inbound: only from ALB SG
  - ECS outbound: to vector store + model provider endpoints

### 9.2 Encryption
- S3 SSE-KMS
- Secrets Manager (default encryption)
- TLS everywhere

### 9.3 IAM
- Separate roles:
  - ECS execution role (pull images, write logs)
  - ECS task role (S3 read/write docs, secrets read)
- Least-privilege policies per service

---

## 10) Operational Runbooks

### 10.1 Deployment rollback
- If canary/blue-green fails:
  - revert traffic to previous target group
  - redeploy last known good task definition

### 10.2 Incident triage checklist
- Check CloudWatch dashboard (errors/latency)
- Check ECS service events (deploy failures)
- Check ALB target health
- Check vector store health & throttling
- Check model provider errors/timeouts

### 10.3 Disaster recovery (baseline)
- S3 versioning + lifecycle
- nightly snapshots/backups (DB/OpenSearch)
- documented restore procedure

---

## 11) Project Generator (LLD)

### 11.1 Inputs
- `project.yml` with:
  - `project_name`, `environment`, `rag_tier`, `traffic_profile`
  - `vector_store_type`, `model_provider`, `region`, `domain`

### 11.2 Outputs
- `infra/envs/<env>/<project>/terraform.tfvars`
- workflow config mapping (optional):
  - `.github/workflows/deploy-<project>-<env>.yml`

### 11.3 Validation rules
- domain required for public endpoints
- prod must have WAF enabled
- advanced tier requires explicit approval flag

---

## 12) Acceptance Criteria (Definition of Done)

### CI/CD
- PR runs lint, tests, scans
- DEV auto deploy works end-to-end
- QA promotion uses immutable image digest
- PROD requires approval and supports rollback

### Terraform
- `terraform plan` clean on PR
- modules reusable across projects
- remote state + locking configured

### Operations
- dashboards and alarms in place
- smoke tests after deployment
- runbooks documented

---

**End of LLD**

