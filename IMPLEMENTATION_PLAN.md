# GitHub Portfolio Repository Plan

> **Goal:** Create a GitHub repository showcasing DevOps documentation framework and operational expertise for hiring managers.

---

## Target Audience

| Audience | What They Care About | How We Address It |
|----------|---------------------|-------------------|
| **Technical Hiring Managers** | Real-world skills, clean code, best practices | Working examples, proper Git hygiene, CI/CD demos |
| **Non-Technical Hiring Managers** | Proof of competence, professionalism | Polished README, clear explanations, visual diagrams |

---

## Proposed Repository Structure

```
{repo-name}/
├── README.md                    # Hero document (first impression)
├── LICENSE                      # MIT or Apache 2.0
├── .github/
│   ├── workflows/
│   │   ├── ci.yml              # Demo CI workflow
│   │   └── deploy.yml          # Demo deploy workflow with rollback
│   ├── ISSUE_TEMPLATE/
│   │   └── bug_report.md       # Shows process thinking
│   └── pull_request_template.md
│
├── docs/                        # Framework documentation
│   ├── 00-framework-overview.md
│   ├── 01-architecture-documentation.md
│   ├── 02-cicd-pipeline.md
│   ├── 03-deployment-runbooks.md
│   ├── 04-data-migration.md
│   └── 05-troubleshooting-patterns.md
│
├── examples/                    # Minimal working examples
│   ├── docker-compose/
│   │   ├── docker-compose.yml
│   │   ├── docker-compose.prod.yml
│   │   └── README.md
│   ├── backup-scripts/
│   │   ├── backup.sh
│   │   ├── restore.sh
│   │   └── README.md
│   └── nginx-proxy/
│       ├── nginx.conf
│       └── README.md
│
└── assets/                      # Images for README
    └── diagrams/
        └── architecture.png
```

---

## Phase 1: Repository Setup (~30 min)

### 1.1 Create Repository

```bash
# Local setup
mkdir automation-playbook-public
cd automation-playbook-public
git init

# Create initial structure
mkdir -p .github/workflows .github/ISSUE_TEMPLATE docs examples/docker-compose examples/backup-scripts examples/nginx-proxy assets/diagrams
```

### 1.2 Create LICENSE

Use MIT License (permissive, portfolio-friendly)

### 1.3 Configure .gitignore

```gitignore
# Secrets
.env
*.pem
*.key

# OS
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/
```

---

## Phase 2: Hero README (~1 hour)

### Structure for Maximum Impact

```markdown
# DevOps Documentation Framework

> A battle-tested methodology for infrastructure documentation, 
> deployment automation, and operational runbooks.

## 🎯 What This Is

[2-3 sentences explaining the framework - non-technical friendly]

## ⚡ Quick Start

[For technical readers who want to dive in]

## 📐 Framework Overview

[Visual diagram + brief explanation]

## 📂 Repository Structure

[Tree diagram with descriptions]

## 🏆 Skills Demonstrated

[Badges + categorized list]

## 📖 Documentation

[Links to /docs with descriptions]

## 🔧 Working Examples

[Links to /examples]

## 📊 Framework Principles

[Key differentiators in a visual format]

## 📜 License

MIT
```

### Badges to Include

```markdown
![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat&logo=docker&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=flat&logo=github-actions&logoColor=white)
![Nginx](https://img.shields.io/badge/Nginx-009639?style=flat&logo=nginx&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-336791?style=flat&logo=postgresql&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=flat&logo=linux&logoColor=black)
![Shell Script](https://img.shields.io/badge/Shell_Script-121011?style=flat&logo=gnu-bash&logoColor=white)
```

---

## Phase 3: Framework Documentation (~1.5 hours)

### 3.1 Adapt Existing Content

Transform your existing workflow docs into the `/docs` structure:

| Source Document | Target | Sanitization Needed |
|-----------------|--------|---------------------|
| `DEVOPS_WORKFLOW_FRAMEWORK.md` | `00-framework-overview.md` | Remove company refs |
| `CONTAINER_STRUCTURE.md` | `01-architecture-documentation.md` | Replace paths, service names |
| `GIT_CICD_WORKFLOW.md` | `02-cicd-pipeline.md` | Replace repo URLs, server names |
| `MANUAL_DEPLOYMENT_PROCEDURE.md` | `03-deployment-runbooks.md` | Generic team references |
| `RSYNC_COMMANDS.md` + `IMAGE_TRANSFER_GUIDE.md` | `04-data-migration.md` | Replace paths |
| *(new)* | `05-troubleshooting-patterns.md` | Consolidate all troubleshooting tables |

### 3.2 Sanitization Checklist

Replace these patterns:

| Original | Replace With |
|----------|--------------|
| `nuzzle`, `Nuzzle` | `sample-app`, `Sample App` |
| `moveforward`, `MoveForward` | `sample-project` |
| `odoo`, `Odoo` | `erp-backend` |
| `/opt/moveforward/` | `/opt/sample-project/` |
| `root@nuzzle` | `user@server` |
| `moveforwardph/` | `sample-org/` |
| Actual IPs/domains | `192.168.x.x`, `example.com` |

---

## Phase 4: Working Examples (~45 min)

### 4.1 Docker Compose Example

**`examples/docker-compose/docker-compose.yml`**

```yaml
version: '3.8'

services:
  web:
    build: ./app
    ports:
      - "8080:8080"
    depends_on:
      - db
    environment:
      - DATABASE_URL=postgres://user:pass@db:5432/app
    volumes:
      - app-data:/var/lib/app
    restart: unless-stopped

  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
      POSTGRES_DB: app
    volumes:
      - db-data:/var/lib/postgresql/data
    restart: unless-stopped

volumes:
  app-data:
  db-data:
```

### 4.2 Backup Script Example

**`examples/backup-scripts/backup.sh`**

```bash
#!/bin/bash
set -euo pipefail

# Configuration
BACKUP_DIR="/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=7

# Create backup
echo "📸 Creating backup at $TIMESTAMP..."
docker exec db pg_dump -U user app > "$BACKUP_DIR/db_$TIMESTAMP.sql"

# Compress
gzip "$BACKUP_DIR/db_$TIMESTAMP.sql"

# Cleanup old backups
find "$BACKUP_DIR" -name "db_*.sql.gz" -mtime +$RETENTION_DAYS -delete

echo "✅ Backup complete: db_$TIMESTAMP.sql.gz"
```

### 4.3 Nginx Reverse Proxy Example

**`examples/nginx-proxy/nginx.conf`**

```nginx
upstream app_backend {
    server web:8080;
}

server {
    listen 80;
    server_name example.com;

    location / {
        proxy_pass http://app_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

---

## Phase 5: GitHub Actions (~30 min)

### 5.1 CI Workflow

**`.github/workflows/ci.yml`**

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  lint:
    name: 📝 Lint Documentation
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Check Markdown Links
        uses: gaurav-nelson/github-action-markdown-link-check@v1
        with:
          folder-path: 'docs/'

  validate:
    name: 🐳 Validate Docker Compose
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Validate docker-compose.yml
        run: docker compose -f examples/docker-compose/docker-compose.yml config

  shellcheck:
    name: 🔍 ShellCheck
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run ShellCheck
        uses: ludeeus/action-shellcheck@master
        with:
          scandir: './examples/backup-scripts'
```

### 5.2 Deploy Workflow (Demo)

**`.github/workflows/deploy.yml`**

```yaml
name: Deploy

on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Target environment'
        required: true
        default: 'staging'
        type: choice
        options:
          - staging
          - production

jobs:
  deploy:
    name: 🚀 Deploy to ${{ inputs.environment }}
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: 📸 Capture current state
        run: |
          echo "Backup SHA: $(git rev-parse HEAD)"
          echo "$(git rev-parse HEAD)" > last-stable.txt
      
      - name: 📋 Preview changes
        run: |
          echo "Files to be deployed:"
          git diff --name-only HEAD~1 || echo "Initial commit"
      
      - name: 🚀 Deploy (simulated)
        run: |
          echo "Deploying to ${{ inputs.environment }}..."
          echo "✅ Deployment complete!"
      
      - name: 💾 Save rollback point
        uses: actions/upload-artifact@v4
        with:
          name: rollback-sha
          path: last-stable.txt
          retention-days: 30
```

---

## Phase 6: Branch Protection Documentation (~15 min)

### Add to README or separate doc

**`docs/branch-protection.md`**

```markdown
# Branch Protection Strategy

## Main Branch Rules

| Rule | Setting | Rationale |
|------|---------|-----------|
| Require pull request | ✅ Enabled | No direct pushes to main |
| Require approvals | 1+ | Code review before merge |
| Require status checks | CI must pass | Prevent broken deployments |
| Require linear history | ✅ Enabled | Clean git log |
| Include administrators | ✅ Enabled | No bypass for anyone |

## Recommended Setup

1. Go to Settings → Branches → Add rule
2. Branch name pattern: `main`
3. Enable above protections
4. Save changes
```

---

## Deliverables Checklist

### Repository Files

- [ ] `README.md` — Hero document with badges, overview, structure
- [ ] `LICENSE` — MIT License
- [ ] `.gitignore` — Standard exclusions
- [ ] `.github/workflows/ci.yml` — Linting, validation
- [ ] `.github/workflows/deploy.yml` — Demo deployment workflow
- [ ] `.github/ISSUE_TEMPLATE/bug_report.md` — Issue template
- [ ] `.github/pull_request_template.md` — PR template

### Documentation

- [ ] `docs/00-framework-overview.md`
- [ ] `docs/01-architecture-documentation.md`
- [ ] `docs/02-cicd-pipeline.md`
- [ ] `docs/03-deployment-runbooks.md`
- [ ] `docs/04-data-migration.md`
- [ ] `docs/05-troubleshooting-patterns.md`
- [ ] `docs/branch-protection.md`

### Working Examples

- [ ] `examples/docker-compose/` — Multi-service compose
- [ ] `examples/backup-scripts/` — Backup/restore scripts
- [ ] `examples/nginx-proxy/` — Reverse proxy config

---

## Success Metrics

| Metric | Target |
|--------|--------|
| README clarity | Non-technical person understands purpose |
| Technical depth | Senior DevOps finds useful patterns |
| Clone-to-run | Examples work with `docker compose up` |
| CI passing | Green badge on main branch |
| Professional feel | Consistent formatting, no typos |

---

## Estimated Time

| Phase | Time |
|-------|------|
| 1. Repository Setup | 30 min |
| 2. Hero README | 1 hour |
| 3. Framework Documentation | 1.5 hours |
| 4. Working Examples | 45 min |
| 5. GitHub Actions | 30 min |
| 6. Branch Protection Docs | 15 min |
| **Total** | **~4.5 hours** |

---

## Next Steps

1. **Approve this plan** or request modifications
2. I will create the repository structure locally
3. You push to GitHub and configure branch protection manually
4. Iterate on README polish based on your feedback
