# RAG App on AWS 

This project is a template for provisioning a RAG (retrieval augmented generation) backend on AWS using Terraform modules and GitHub Actions. It is designed for use-case based infrastructure composition per project and supports DEV, QA, and PROD environments.

## What is included

- CI/CD workflows for linting, packaging Lambda code, planning, and applying Terraform
- Reusable Terraform modules for network, storage, compute, API, auth, database, and monitoring
- Use-case modules that assemble the platform modules for specific product needs
- Per-project tfvars to select a use case and override environment settings

## Repository structure

```
.
|-- .github/workflows
|   |-- ci.yml
|   |-- deploy.yml
|   `-- cleanup.yml
|-- environments
|   |-- dev
|   |-- qa
|   `-- prod
|-- modules
|   |-- api
|   |-- auth
|   |-- compute
|   |-- database
|   |-- monitoring
|   |-- network
|   `-- storage
|-- mcp_servers
|   `-- web_search_mcp_server.py
|-- rag_ui
|   |-- app.py
|   `-- README.md
|-- use_cases
|   |-- rag-core
|   `-- rag-with-eval
|-- projects
|   `-- sample-project
|-- scripts
|   `-- package_lambdas.sh
`-- src
    |-- auth_handler
    |-- db_init
    |-- document_processor
    |-- query_handler
    `-- upload_handler
```

## Use-case based deployment

Each project selects a use case via its tfvars. The environment folder provides the Terraform entrypoint.

Example project inputs are stored in `projects/sample-project`:

- `dev.tfvars`
- `qa.tfvars`
- `prod.tfvars`

Use cases:

- `rag-core` - core RAG APIs and data storage
- `rag-with-eval` - core RAG plus evaluation endpoint

## Local workflow

1. Package Lambda functions:

```
./scripts/package_lambdas.sh
```

2. Initialize Terraform for an environment:

```
terraform -chdir=environments/dev init
```

3. Plan with a project tfvars file:

```
terraform -chdir=environments/dev plan -var-file=../../projects/sample-project/dev.tfvars
```

4. Apply:

```
terraform -chdir=environments/dev apply -var-file=../../projects/sample-project/dev.tfvars
```

## CI/CD overview

- `ci.yml` runs formatting and validation checks.
- `deploy.yml` packages Lambda code, runs Terraform plan, and applies on branch pushes.
- `cleanup.yml` destroys a selected environment on manual trigger.

Branch mapping:

- `develop` -> `dev`
- `qa` -> `qa`
- `main` -> `prod`

## UI and MCP server

- `rag_ui/` contains the Streamlit UI for uploads, queries, and evaluation.
- `mcp_servers/` provides a free DuckDuckGo-based MCP web search server (no API key required).

## Notes

- Update the project tfvars to set `project_name`, `use_case`, and tags.
- Make sure GitHub repo secrets are set for AWS credentials.
