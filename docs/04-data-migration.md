# Data Migration Guide

> **Purpose:** Reproducible procedures for transferring data between environments.

> [!NOTE]
> **Scope Exclusions:** The following topics are intentionally excluded from this guide as implementation varies depending on the project, database technology, and data structure:
> - **Backup validation** — Verification methods differ by database engine (PostgreSQL, MySQL, MongoDB, etc.)
> - **Encryption for backups** — Encryption requirements depend on compliance needs and key management infrastructure
> - **Staging environment testing** — Staging architecture varies by project deployment model
> - **Schema version tracking** — Migration tooling (Flyway, Alembic, Liquibase, etc.) is project-specific
>
> Consult project-specific documentation for implementation details on these topics.

---

## Migration Scenarios

| Scenario | Method | Use Case |
|----------|--------|----------|
| Database migration | pg_dump / pg_restore | Moving to new server |
| Volume backup | tar + rsync | Disaster recovery |
| Docker image transfer | docker save/load | No registry access |
| File sync | rsync | Code/config updates |

---

## Database Migration

### Export from Source

```bash
# SSH to source server
ssh user@source-server

# Create database dump
docker exec sample-project-db-1 pg_dump -U user app > /tmp/db_export.sql

# Compress
gzip /tmp/db_export.sql

# Check size
ls -lh /tmp/db_export.sql.gz
```

### Transfer

```bash
# From local machine (or destination)
rsync -avz --progress \
  user@source-server:/tmp/db_export.sql.gz \
  /tmp/
```

### Import to Destination

```bash
# SSH to destination
ssh user@dest-server

# Copy to server
rsync -avz /tmp/db_export.sql.gz user@dest-server:/tmp/

# Decompress
gunzip /tmp/db_export.sql.gz

# Import (⚠️ DESTRUCTIVE)
docker exec -i sample-project-db-1 psql -U user -d app < /tmp/db_export.sql
```

---

## Docker Volume Backup

### Create Compressed Backup

```bash
# Stop container for consistency (optional but recommended for DB)
docker stop sample-project-db-1

# Create backup
tar -cf - -C /var/lib/docker/volumes/sample-project_db-data _data | gzip > db-data.tar.gz

# Start container
docker start sample-project-db-1

# Check backup
ls -lh db-data.tar.gz
```

### Transfer Volume Backup

```bash
# Using rsync with resume support
rsync -avz --progress --partial \
  user@source:/opt/backups/db-data.tar.gz \
  /opt/backups/
```

### Restore Volume

```bash
# Stop container
docker stop sample-project-db-1

# Remove existing data
docker volume rm sample-project_db-data
docker volume create sample-project_db-data

# Restore
tar -xzf db-data.tar.gz -C /var/lib/docker/volumes/sample-project_db-data/

# Start container
docker start sample-project-db-1
```

---

## Docker Image Transfer

### Export Image

```bash
# On source server
docker save sample-project-web:latest | gzip > web-image.tar.gz

# Check size
ls -lh web-image.tar.gz
```

### Transfer Image

```bash
# Using rsync
rsync -avz --progress --partial \
  user@source:/opt/images/web-image.tar.gz \
  /opt/images/
```

### Import Image

```bash
# On destination
gunzip -c web-image.tar.gz | docker load

# Verify
docker images | grep sample-project
```

---

## rsync Command Reference

### Basic Flags

| Flag | Meaning |
|------|---------|
| `-a` | Archive mode (preserves permissions, timestamps) |
| `-v` | Verbose output |
| `-z` | Compress during transfer |
| `--progress` | Show transfer progress |
| `--partial` | Keep partial files (allows resume) |
| `--append-verify` | Resume and verify with checksum |

### Common Commands

```bash
# Basic transfer
rsync -avz source/ destination/

# With progress and resume
rsync -avz --progress --partial source/ destination/

# Dry run (preview)
rsync -avz --dry-run source/ destination/

# Exclude patterns
rsync -avz --exclude='*.log' --exclude='node_modules/' source/ destination/

# With SSH key
rsync -avz -e "ssh -i ~/.ssh/id_rsa" user@server:/path/ /local/path/
```

---

## Transfer Verification

### Compare File Sizes

```bash
# Local
ls -lh /local/backup.tar.gz

# Remote
ssh user@server "ls -lh /remote/backup.tar.gz"
```

### Checksum Verification

```bash
# Generate checksum on source
ssh user@source "md5sum /path/to/file.tar.gz"

# Compare with local
md5sum /local/file.tar.gz
```

### Database Row Count

```bash
# Source
docker exec source-db psql -U user -d app -c "SELECT COUNT(*) FROM users;"

# Destination
docker exec dest-db psql -U user -d app -c "SELECT COUNT(*) FROM users;"
```

---

## Migration Checklist

### Pre-Migration

- [ ] Document source configuration
- [ ] Estimate data sizes
- [ ] Verify destination has sufficient space
- [ ] Plan maintenance window
- [ ] Notify affected users

### During Migration

- [ ] Create source backups
- [ ] Stop source services (if required)
- [ ] Transfer data
- [ ] Verify transfer integrity
- [ ] Import to destination

### Post-Migration

- [ ] Start destination services
- [ ] Run smoke tests
- [ ] Verify data integrity
- [ ] Update DNS/routing (if applicable)
- [ ] Monitor for issues
- [ ] Keep source backup for 7+ days

---

## Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| Transfer interrupted | Network issue | Use `--partial --append-verify` |
| Permission denied | SSH key issue | Check key path, permissions |
| Disk full | Insufficient space | Clean up, use compression |
| Checksum mismatch | Corrupted transfer | Delete and re-transfer |
| Import fails | Schema mismatch | Check database versions |

---

## Performance Tips

### Large Transfers

```bash
# Use compression at source (faster than rsync -z for large files)
gzip -1 large-file.sql  # Fast compression
rsync -av --progress large-file.sql.gz destination/
```

### Parallel Transfers

```bash
# Multiple files in parallel
ls *.tar.gz | xargs -P 4 -I {} rsync -av {} destination/
```

### Bandwidth Limiting

```bash
# Limit to 10 MB/s
rsync -avz --bwlimit=10000 source/ destination/
```
