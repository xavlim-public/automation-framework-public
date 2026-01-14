# Backup Scripts

Production-ready backup and restore scripts for PostgreSQL databases.

## Files

| Script | Purpose |
|--------|---------|
| `backup.sh` | Create timestamped database backup |
| `restore.sh` | Restore database from backup |

## Quick Start

```bash
# Make scripts executable
chmod +x backup.sh restore.sh

# Create a backup
./backup.sh

# Restore from backup
./restore.sh /path/to/backup.sql.gz
```

## Features

### backup.sh
- ✅ Timestamped backups
- ✅ Automatic compression (gzip)
- ✅ Retention policy (configurable days)
- ✅ Error handling with `set -euo pipefail`
- ✅ Clear status messages

### restore.sh
- ✅ Safety confirmation prompt
- ✅ Automatic decompression
- ✅ Pre-restore backup option
- ✅ Database recreation

## Configuration

Edit the scripts to customize:

```bash
# backup.sh
BACKUP_DIR="/backups"        # Where backups are stored
CONTAINER_NAME="db"          # Docker container name
DB_USER="user"               # Database user
DB_NAME="app"                # Database name
RETENTION_DAYS=7             # Days to keep backups
```

## Cron Schedule

Add to crontab for automated backups:

```bash
# Daily backup at 2 AM
0 2 * * * /opt/scripts/backup.sh >> /var/log/backup.log 2>&1

# Weekly full backup on Sundays
0 3 * * 0 /opt/scripts/backup.sh --full >> /var/log/backup.log 2>&1
```

## Best Practices

1. **Test restores regularly** - A backup is only as good as its restore
2. **Store backups off-site** - Sync to S3, GCS, or another server
3. **Monitor backup sizes** - Unusual sizes may indicate issues
4. **Encrypt sensitive backups** - Use GPG for sensitive data
