# RAG Application Backend

This is the containerized backend for the RAG platform, running on AWS ECS Fargate.

## API Endpoints

- `GET /health`: Health check for ALB.
- `GET /ready`: Readiness check for dependencies.
- `POST /api/v1/query`: Query the RAG system.
- `POST /api/v1/upload`: Upload documents for ingestion.

## Local Development

```bash
cd src/app
pip install -r requirements.txt
uvicorn main:app --reload
```

## Docker Build

```bash
docker build -t rag-app .
docker run -p 8000:8000 rag-app
```
