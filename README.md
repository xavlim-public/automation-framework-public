# DevOps Documentation Framework

[![CI](https://img.shields.io/badge/CI-passing-brightgreen?style=flat&logo=github-actions&logoColor=white)](https://github.com/xavlim-public/automation-framework-public?tab=readme-ov-file)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat&logo=docker&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=flat&logo=github-actions&logoColor=white)
![Nginx](https://img.shields.io/badge/Nginx-009639?style=flat&logo=nginx&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-336791?style=flat&logo=postgresql&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=flat&logo=linux&logoColor=black)
![Shell Script](https://img.shields.io/badge/Shell_Script-121011?style=flat&logo=gnu-bash&logoColor=white)

---

## 🎯 What This Is

This repository showcases my **documentation-first engineering approach** to DevOps and agentic automation, honed from real-world experience managing containerized production environments, developing ETL/ELT pipelines, end-to-end Data Engineering & Data Governance solution development. It demonstrates how to create maintainable, actionable documentation & workflows that:

- **Reduces deployment risk** with backup-first procedures
- **Enables quick recovery** through documented rollback steps
- **Scales knowledge** across teams with copy-paste ready commands
- **Prevents open emergencies** with comprehensive troubleshooting guides

---

## 📐 Framework Overview

```
┌─────────────────────────────────────────────────────────────┐
│              DOCUMENTATION-FIRST DEVOPS                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│   📋 Architecture    →  Know your system topology            │
│   🚀 CI/CD Pipeline  →  Safe, traceable deployments         │
│   📖 Runbooks        →  Step-by-step operational guides     │
│   🔄 Data Migration  →  Reproducible transfer procedures    │
│   🔧 Troubleshooting →  Quick fixes for common issues       │
│   🤖 Agent LLM Ready →  Token-efficient, parseable templates│
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 📖 Documentation

| Document | Description |
|----------|-------------|
| [Framework Overview](docs/00-framework-overview.md) | Philosophy and core principles |
| [Architecture Documentation](docs/01-architecture-documentation.md) | Codebase/Project structure, Container mappings, volumes, network topology |
| [CI/CD Pipeline](docs/02-cicd-pipeline.md) | Deployment workflows, rollback procedures |
| [Deployment Runbooks](docs/03-deployment-runbooks.md) | Step-by-step operational guides |
| [Data Migration](docs/04-data-migration.md) | Database and volume transfer procedures |

---

## 📂 Repository Structure

```
automation-playbook-public/
├── README.md                    # You are here
├── LICENSE                      # MIT License
├── .github/
│   ├── workflows/
│   │   ├── ci.yml              # CI/CD with pre-deploy backup
│   │   └── rollback.yml        # One-click rollback to any commit
│   ├── ISSUE_TEMPLATE/
│   │   └── bug_report.md
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
└── examples/                    # Deployment-ready templates
    ├── docker-compose/          # Multi-service configuration
    ├── backup-scripts/          # Database backup & restore
    └── nginx-proxy/             # Reverse proxy configuration
```

---

## 📦 Template Examples

Production-ready templates designed for quick adaptation to your projects.

### Docker Compose

Multi-service configuration with health checks, environment separation, and volume management:

```bash
cd examples/docker-compose
docker compose config  # Validate configuration
```

### Backup Scripts

Database backup and restore with compression, retention policy, and error handling:

```bash
cd examples/backup-scripts
./backup.sh   # Creates timestamped, compressed backup
./restore.sh  # Restore with safety prompts
```

### Nginx Reverse Proxy

Reverse proxy with security headers, gzip compression, and WebSocket support:

```bash
cd examples/nginx-proxy
docker run --rm -v $(pwd):/etc/nginx/conf.d:ro nginx:alpine nginx -t
```

---

## 🚀 Getting Started

1. **Explore the docs** — Start with [Framework Overview](docs/00-framework-overview.md)
2. **Adapt the templates** — Copy examples to your own projects

---

## ⚡ Quick Start

```bash
# Clone the repository
git clone https://github.com/sample-org/automation-playbook-public.git
cd automation-playbook-public

# Explore the examples
cd examples/docker-compose
docker compose config

# Run a backup
cd ../backup-scripts
chmod +x backup.sh restore.sh
./backup.sh
```

---

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

*This framework was initially developed from my real-world experience managing containerized production environments with React frontends, Node.js APIs, and ERP backends.*
