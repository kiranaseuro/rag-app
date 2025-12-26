# DuckDuckGo MCP Web Search Server

This MCP server provides a free web search tool backed by DuckDuckGo. It uses stateless HTTP streaming and does not require an API key.

## Features

- Free DuckDuckGo search via open-source client library
- Stateless HTTP transport with JSON responses
- Health check endpoint for monitoring

## Installation

```bash
git clone <your-repo>
cd rag-app-on-aws-blueprint/mcp_servers

pip install uv
uv venv
.venv\Scripts\activate
uv pip install -r requirements.txt
```

## Configuration

Create a `.env` file (optional):

```env
DDG_REGION=us-en
DDG_SAFE_SEARCH=moderate
```

## Usage

```bash
python web_search_mcp_server.py --host localhost --port 8000
```

If your Lambda functions need to reach the MCP server, expose it via a tunnel such as Cloudflare Tunnel or Serveo.
