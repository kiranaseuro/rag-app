# RAG UI (Streamlit)

This Streamlit UI is a local frontend for the RAG backend deployed by this repository. It supports document upload, querying, and optional web search via an MCP server.

## Features

- Cognito-based authentication with token refresh
- Document upload and status tracking
- Query interface with RAG evaluation metrics
- Optional MCP web search integration

## Prerequisites

- Python 3.11+
- Backend API deployed (see repository root README)

## Installation

```bash
git clone <your-repo>
cd rag-app-on-aws-blueprint/rag_ui

pip install uv
uv venv
.venv\Scripts\activate
uv pip install -r requirements.txt
```

## Configuration

Create a `.env` file:

```env
# RAG Application API Configuration
API_ENDPOINT=https://your-api-gateway-url.amazonaws.com/stage
UPLOAD_ENDPOINT=/upload
QUERY_ENDPOINT=/query
AUTH_ENDPOINT=/auth

# Default user settings
DEFAULT_USER_ID=test-user

# Cognito Configuration
COGNITO_CLIENT_ID=your_cognito_client_id

# Enabling/disabling evaluation
ENABLE_EVALUATION="true"
```

The UI supports open-source model choices (for example, Llama or Mistral). Ensure your backend accepts the selected model name.

## Usage

```bash
streamlit run app.py
```

Visit `http://localhost:8501`, log in, upload documents, and run queries.
