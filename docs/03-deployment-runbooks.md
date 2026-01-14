# Deployment Runbooks

> **Purpose:** Safe, documented manual procedures for deployment operations.

---

## Runbook Philosophy

Every operational procedure follows this pattern:

```
1. ANNOUNCE → Notify team before changes
2. BACKUP  → Create timestamped snapshot
3. LOG     → Record in change log
4. EXECUTE → Make the change
5. VERIFY  → Confirm functionality
6. ANNOUNCE → Notify completion status
```

---

## Pre-Deployment Checklist

- [ ] Code reviewed and approved
- [ ] CI/CD checks passing
- [ ] Backup created
- [ ] Team notified
- [ ] Rollback plan ready

---

## Standard Deployment

### Step 1: Announce

Post in team channel **before** starting:

```
🚀 STARTING DEPLOYMENT
Environment: [production/staging]
Changes: [brief description]
ETA: [expected time]
Deployer: [your name]
```

### Step 2: Create Backup

```bash
# SSH to server
ssh user@server

# Navigate to project
cd /opt/sample-project

# Save current state
CURRENT_SHA=$(git rev-parse HEAD)
echo "$CURRENT_SHA" > /opt/backups/pre-deploy-$(date +%Y%m%d_%H%M%S).txt
echo "📸 Backup SHA: $CURRENT_SHA"

# Backup database (if applicable)
./scripts/backup.sh
```

### Step 3: Deploy

```bash
# Pull latest changes
git fetch --all

# Preview changes
echo "📋 Files that will change:"
git diff --name-only HEAD origin/main

# Apply changes
git checkout main
git reset --hard origin/main

# Rebuild and restart
docker compose -f docker-compose.yml -f docker-compose.prod.yml build
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

### Step 4: Verify

```bash
# Check container status
docker compose ps

# View logs for errors
docker compose logs --tail 50

# Test health endpoint
curl -s http://localhost/health
```

### Step 5: Announce Completion

```
✅ DEPLOYMENT COMPLETE
Environment: [production/staging]
Commit: [new SHA]
Status: Healthy / ⚠️ Issues Found
Duration: [time taken]
```

---

## Rollback Procedure

### When to Rollback

- ❌ Application not responding
- ❌ Critical errors in logs
- ❌ User-reported issues after deploy
- ❌ Performance degradation

### Emergency Rollback

```bash
# 1. Announce
echo "⚠️ INITIATING ROLLBACK"

# 2. Get last stable SHA
STABLE_SHA=$(cat /opt/backups/last-stable.txt)
echo "Rolling back to: $STABLE_SHA"

# 3. Rollback
cd /opt/sample-project
git checkout $STABLE_SHA

# 4. Restart
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# 5. Verify
docker compose ps
curl -s http://localhost/health
```

### Announce Rollback

```
⚠️ ROLLED BACK
Environment: [production/staging]
Reverted to: [SHA]
Reason: [what broke]
Next steps: [investigation plan]
```

---

## Service-Specific Operations

### Restart Single Service

```bash
# Restart only the web service
docker compose restart web

# Restart with rebuild
docker compose up -d --build web
```

### View Service Logs

```bash
# Follow logs
docker compose logs -f web

# Last 100 lines
docker compose logs --tail 100 web

# Since timestamp
docker compose logs --since "2024-01-01T10:00:00" web
```

### Enter Container Shell

```bash
# Interactive shell
docker exec -it sample-project-web-1 sh

# Run single command
docker exec sample-project-web-1 cat /etc/app/config.yml
```

---

## Database Operations

### Create Manual Backup

```bash
cd /opt/sample-project
./examples/backup-scripts/backup.sh
```

### Restore from Backup

```bash
# ⚠️ DESTRUCTIVE - Creates backup first
./examples/backup-scripts/restore.sh /opt/backups/app_20260113_020000.sql.gz
```

### Database Shell

```bash
docker exec -it sample-project-db-1 psql -U user -d app
```

---

## Configuration Changes

### Update Environment Variables

```bash
# 1. Edit .env file
nano /opt/sample-project/.env

# 2. Recreate containers
docker compose up -d
```

### Update Nginx Configuration

```bash
# 1. Edit config
nano /opt/sample-project/src/config/nginx/conf.d/default.conf

# 2. Test syntax
docker exec sample-project-nginx-1 nginx -t

# 3. Reload (no downtime)
docker exec sample-project-nginx-1 nginx -s reload
```

---

## Change Log Template

Track all changes in a shared document:

| Date | Time | Person | Environment | Change | Backup | Status |
|------|------|--------|-------------|--------|--------|--------|
| 2026-01-13 | 10:30 | @john | production | Updated API config | pre-deploy-20260113_1030.txt | ✅ Success |
| 2026-01-12 | 15:00 | @jane | staging | New feature deploy | pre-deploy-20260112_1500.txt | ✅ Success |

---

## Communication Templates

### Starting Work

```
🔧 STARTING WORK
File: [filename]
Service: [service name]
What: [brief description]
ETA: [expected time]
```

### Completed

```
✅ DEPLOYED
File: [filename]
Service: [service name]
What: [brief description]
Backup: [backup reference]
Status: Working / ⚠️ Issues found
```

### Issue Found

```
⚠️ ISSUE DETECTED
Service: [service name]
Symptom: [what's wrong]
Impact: [who's affected]
Action: [what you're doing]
```

---

## Troubleshooting Quick Reference

| Issue | First Check | Solution |
|-------|-------------|----------|
| Container won't start | `docker compose logs web` | Fix config, rebuild |
| 502 Bad Gateway | Is backend running? | Restart backend service |
| Database connection error | Is db container healthy? | Check db logs, restart |
| SSL certificate error | Certificate expired? | Renew with certbot |
| Disk full | `df -h` | Clean old backups, docker prune |
