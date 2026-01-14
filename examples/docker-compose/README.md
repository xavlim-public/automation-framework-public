# Docker Compose Examples

Production-ready Docker Compose configurations for multi-service deployments.

## Files

| File | Purpose |
|------|---------|
| `docker-compose.yml` | Base configuration with core services |
| `docker-compose.prod.yml` | Production overrides (resource limits, restart policies) |

## Quick Start

```bash
# Development
docker compose up -d

# Production
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

## Architecture

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   nginx     │────▶│    web      │────▶│     db      │
│  (proxy)    │     │   (app)     │     │ (postgres)  │
└─────────────┘     └─────────────┘     └─────────────┘
      :80                :8080              :5432
```

## Services

### web
- Application server
- Depends on database
- Exposes port 8080

### db
- PostgreSQL 15 Alpine
- Persistent volume for data
- Health checks enabled

### nginx
- Reverse proxy
- SSL termination ready
- Load balancing capable

## Volumes

| Volume | Purpose | Backup Priority |
|--------|---------|-----------------|
| `db-data` | PostgreSQL data | ⭐⭐⭐⭐⭐ Critical |
| `app-data` | Application data | ⭐⭐⭐⭐ High |

## Environment Variables

Create a `.env` file:

```env
POSTGRES_USER=app_user
POSTGRES_PASSWORD=secure_password
POSTGRES_DB=app_db
```

## Commands

```bash
# Start services
docker compose up -d

# View logs
docker compose logs -f

# Stop services
docker compose down

# Stop and remove volumes (⚠️ destructive)
docker compose down -v

# Rebuild after code changes
docker compose up -d --build
```
