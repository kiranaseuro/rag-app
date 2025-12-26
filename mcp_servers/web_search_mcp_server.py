"""
DuckDuckGo based Web Search MCP Server with HTTP Streamable Transport
Configured for stateless HTTP requests and JSON responses.
"""
import os
import logging
import asyncio
import argparse
from typing import Any, Dict, List

from mcp.server.fastmcp import FastMCP
import uvicorn
from dotenv import load_dotenv
from duckduckgo_search import DDGS

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

load_dotenv()

# Initialize FastMCP server with Streamable HTTP transport
mcp = FastMCP(
    name="DuckDuckGo Search Server",
    instructions="Web search server using DuckDuckGo",
    json_response=True,
    stateless_http=True,
    warn_on_duplicate_tools=True,
    warn_on_duplicate_resources=True,
    warn_on_duplicate_prompts=True,
    debug=True,
)

DDG_REGION = os.getenv("DDG_REGION", "us-en")
DDG_SAFE_SEARCH = os.getenv("DDG_SAFE_SEARCH", "moderate")


class DuckDuckGoClient:
    """Client for interacting with DuckDuckGo search."""

    async def search(self, query: str, num_results: int = 10, region: str = None, safesearch: str = None) -> List[Dict[str, Any]]:
        """Perform a search using DuckDuckGo."""
        if not query or not query.strip():
            return []

        region = region or DDG_REGION
        safesearch = safesearch or DDG_SAFE_SEARCH
        max_results = min(max(num_results, 1), 50)

        def run_search():
            with DDGS() as ddgs:
                return list(ddgs.text(query, region=region, safesearch=safesearch, max_results=max_results))

        loop = asyncio.get_event_loop()
        try:
            results = await loop.run_in_executor(None, run_search)
            return results
        except Exception as exc:
            logger.error("DuckDuckGo search error: %s", exc)
            raise


ddg_client = DuckDuckGoClient()


@mcp.tool(
    name="web_search",
    description="Search the web using DuckDuckGo with support for region and safe search.",
)
async def web_search(query: str, num_results: int = 10, region: str = None, safesearch: str = None) -> str:
    """
    Search the web using DuckDuckGo.

    Args:
        query: The search query (required)
        num_results: Number of results to return (default: 10, max: 50)
        region: Optional region (example: "us-en", "uk-en")
        safesearch: Optional safe search level ("off", "moderate", "on")

    Returns:
        Formatted search results optimized for Lambda client consumption
    """
    if not query or not query.strip():
        return "ERROR: Search query cannot be empty."

    try:
        logger.info("Lambda client search request: '%s' (%s results, region: %s)", query, num_results, region)
        results = await ddg_client.search(query, num_results, region, safesearch)

        formatted_results = []
        formatted_results.append(f"SEARCH RESULTS FOR: {query}")
        formatted_results.append(f"REGION: {region or DDG_REGION}")
        formatted_results.append("-" * 60)

        if results:
            formatted_results.append("\nRESULTS:")
            for idx, result in enumerate(results[:num_results], 1):
                title = (result.get("title") or "No title").strip()
                link = (result.get("href") or "No link").strip()
                snippet = (result.get("body") or "No description").strip()

                formatted_results.append(f"\n{idx}. {title}")
                formatted_results.append(f"   URL: {link}")
                formatted_results.append(f"   Summary: {snippet}")
        else:
            formatted_results.append("No results found.")

        return "\n".join(formatted_results)
    except Exception as exc:
        error_msg = f"Search error: {exc}"
        logger.error("Lambda client search failed: %s", error_msg)
        return f"ERROR: {error_msg}"


@mcp.tool(
    name="health_check",
    description="Health check endpoint for monitoring the MCP server",
)
async def health_check() -> str:
    """
    Health check for client monitoring.

    Returns:
        Server status information
    """
    import time

    status_items = [
        "STATUS: HEALTHY",
        f"TIMESTAMP: {int(time.time())}",
        "SERVER: DuckDuckGo MCP Server",
        "TRANSPORT: Streamable HTTP (Stateless)",
        "CONFIGURATION:",
        f"  - JSON Response: {mcp.settings.json_response}",
        f"  - Stateless: {mcp.settings.stateless_http}",
        f"REGION: {DDG_REGION}",
        f"SAFE_SEARCH: {DDG_SAFE_SEARCH}",
        "TOOLS: web_search, health_check",
    ]

    return "\n".join(status_items)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Run MCP DuckDuckGo server optimized for AWS Lambda clients")
    parser.add_argument("--port", type=int, default=8000, help="Port to listen on")
    parser.add_argument("--host", type=str, default="localhost", help="Host to bind to (0.0.0.0 for production)")
    parser.add_argument("--log-level", type=str, default="INFO", choices=["DEBUG", "INFO", "WARNING", "ERROR"])
    args = parser.parse_args()

    logging.getLogger().setLevel(getattr(logging, args.log_level))
    mcp.settings.host = args.host
    mcp.settings.port = args.port
    mcp.settings.log_level = args.log_level

    print("DuckDuckGo MCP Server based on Streamable HTTP Transport")
    print(f"MCP Endpoint: http://{args.host}:{args.port}{mcp.settings.streamable_http_path}")
    print(f"Health Check: http://{args.host}:{args.port}/health")
    print(f"Server Info: http://{args.host}:{args.port}/info")
    print("Transport: streamable_http")
    print("Mode: stateless (no session persistence needed)")

    try:
        uvicorn.run(
            mcp.streamable_http_app(),
            host=args.host,
            port=args.port,
            log_level=args.log_level.lower(),
            access_log=True,
            workers=1,
        )
    except KeyboardInterrupt:
        print("\nServer stopped")
    except Exception as exc:
        print(f"Server error: {exc}")
        logger.error("Server startup failed: %s", exc)
