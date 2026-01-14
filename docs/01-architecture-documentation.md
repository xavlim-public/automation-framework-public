# Architecture Documentation

> **Purpose:** Provide a complete mental model of system topology, including container mappings, volume structures, and network configuration.

---

## Container Structure

A containerized application typically consists of multiple services working together. This document maps the relationships between:

- Host directories (bind mounts)
- Docker volumes (persistent storage)
- Container paths (internal filesystem)

---

## Host Directory Structure

```
/opt/sample-project/
├── docker-compose.yml        # Base configuration
├── docker-compose.prod.yml   # Production overrides
├── docker-compose.dev.yml    # Development overrides
├── backup/                   # Local backups directory
└── src/
    ├── app/                  # Application source code
    ├── config/
    │   ├── app.conf          # Application config
    │   └── nginx/
    │       └── conf.d/
    └── backups/
        └── db/               # DB initialization scripts
```

---

## Container Mount Maps

Understanding how host files map to container paths is critical for debugging and maintenance.

### Web Application Container

| Source (Host) | Destination (Container) | Type | Description |
|---------------|-------------------------|------|-------------|
| `./src/app` | `/app` | **Bind** | Application source code |
| `./src/config` | `/etc/app` | **Bind** | Configuration files |
| `app-data` (vol) | `/var/lib/app` | **Volume** | Persistent app data |

### Database Container (PostgreSQL)

| Source (Host) | Destination (Container) | Type | Description |
|---------------|-------------------------|------|-------------|
| `./src/backups/db` | `/docker-entrypoint-initdb.d` | **Bind** | Init scripts (first start only) |
| `database-data` (vol) | `/var/lib/postgresql/data/pgdata` | **Volume** | PostgreSQL data files |

### Nginx Proxy Container

| Source (Host) | Destination (Container) | Type | Description |
|---------------|-------------------------|------|-------------|
| `./src/config/nginx/conf.d` | `/etc/nginx/conf.d` | **Bind** | Custom proxy config |
| `/var/run/docker.sock` | `/tmp/docker.sock` | **Bind** | Docker API (read-only) |
| `certs` (vol) | `/etc/nginx/certs` | **Volume** | SSL/TLS certificates |

---

## Docker Volumes

Persistent data stored in Docker's managed area (`/var/lib/docker/volumes/`).

| Volume Name | Usage | Backup Priority |
|-------------|-------|-----------------| 
| `database-data` | PostgreSQL Data | ⭐⭐⭐⭐⭐ **CRITICAL** |
| `app-data` | Application Data | ⭐⭐⭐⭐ **HIGH** |
| `certs` | SSL/TLS Certificates | ⭐⭐⭐⭐ HIGH |
| `nginx-conf` | Nginx configs | ⭐⭐ LOW (regenerated) |

---

## Backup Priority Summary

| Priority | What to Backup | Why |
|----------|----------------|-----|
| ⭐⭐⭐⭐⭐ | `database-data` | **Your entire database!** |
| ⭐⭐⭐⭐⭐ | `app-data` | User uploads, attachments |
| ⭐⭐⭐⭐ | `./src/` | Your custom code |
| ⭐⭐⭐⭐ | `certs` | SSL certificates |
| ⭐⭐⭐ | `./src/config` | All configurations |

---

## Network Topology

```
┌─────────────────────────────────────────────────────────────┐
│                        Internet                              │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼ :80/:443
              ┌───────────────────────┐
              │    Nginx (Proxy)      │
              │   - SSL termination   │
              │   - Load balancing    │
              └───────────┬───────────┘
                          │
          ┌───────────────┼───────────────┐
          │               │               │
          ▼ :8080         ▼ :8081         ▼ :8082
    ┌───────────┐   ┌───────────┐   ┌───────────┐
    │   Web 1   │   │   Web 2   │   │   Web 3   │
    │   (App)   │   │   (App)   │   │   (App)   │
    └─────┬─────┘   └─────┬─────┘   └─────┬─────┘
          │               │               │
          └───────────────┼───────────────┘
                          │
                          ▼ :5432
              ┌───────────────────────┐
              │     PostgreSQL        │
              │     (Database)        │
              └───────────────────────┘
```

---

## Critical Path Notes

> [!WARNING]
> **Volume Mount Order**
> If bind mounts overlay Docker image directories, ensure the host directory contains all required files. Missing files will cause container failures.

> [!NOTE]
> **Database Initialization**
> Files in `/docker-entrypoint-initdb.d` only run on **first container start** (when database is empty). They won't run on subsequent restarts.

> [!IMPORTANT]
> **Configuration Changes**
> Changes to bind-mounted config files often require container restart to take effect:
> ```bash
> docker compose restart web
> ```

---

## Useful Commands

```bash
# View all container mounts
docker inspect <container> --format '{{json .Mounts}}' | jq

# Enter container shell
docker exec -it <container> sh

# View container logs
docker logs -f <container>

# Check volume usage
docker system df -v
```

---

## 🤖 Agent LLM Integration

This documentation is structured for **Agent LLM consumption**, enabling automated workflows:

| Artifact | Agent Usage |
|----------|-------------|
| **Issue Templates** | Automated triage via "Steps to Reproduce" parsing |
| **PR Templates** | Changelog generation from "Changes Made" section |
| **Mount Maps** | Quick path resolution for debugging prompts |
| **Backup Tables** | Priority-based backup script generation |

> **Token Efficiency:** Structured tables and consistent formatting reduce context tokens required for Agent LLMs to understand system topology.

