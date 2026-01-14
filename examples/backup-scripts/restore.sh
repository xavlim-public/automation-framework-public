#!/bin/bash
#
# Database Restore Script
# Restores PostgreSQL database from a backup file
#
set -euo pipefail

# ============================================================================
# Configuration
# ============================================================================
CONTAINER_NAME="${DB_CONTAINER:-db}"
DB_USER="${POSTGRES_USER:-user}"
DB_NAME="${POSTGRES_DB:-app}"

# ============================================================================
# Functions
# ============================================================================
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

error() {
    log "❌ ERROR: $1" >&2
    exit 1
}

confirm() {
    read -p "⚠️  $1 [y/N]: " response
    case "$response" in
        [yY][eE][sS]|[yY]) return 0 ;;
        *) return 1 ;;
    esac
}

# ============================================================================
# Argument parsing
# ============================================================================
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <backup_file.sql.gz>"
    echo ""
    echo "Example:"
    echo "  $0 /backups/app_20260113_020000.sql.gz"
    exit 1
fi

BACKUP_FILE="$1"

# ============================================================================
# Pre-flight checks
# ============================================================================
log "🔍 Running pre-flight checks..."

# Check if backup file exists
if [[ ! -f "$BACKUP_FILE" ]]; then
    error "Backup file not found: $BACKUP_FILE"
fi

# Check if container is running
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    error "Container '$CONTAINER_NAME' is not running"
fi

# ============================================================================
# Confirmation
# ============================================================================
log ""
log "=========================================="
log "⚠️  DATABASE RESTORE WARNING"
log "=========================================="
log "This will:"
log "  1. Drop the existing '$DB_NAME' database"
log "  2. Create a new '$DB_NAME' database"
log "  3. Restore data from: $BACKUP_FILE"
log ""
log "Container: $CONTAINER_NAME"
log "Database: $DB_NAME"
log "=========================================="
log ""

if ! confirm "Are you sure you want to proceed?"; then
    log "❌ Restore cancelled by user"
    exit 0
fi

# ============================================================================
# Optional: Create backup before restore
# ============================================================================
if confirm "Create a backup of current database before restoring?"; then
    log "📸 Creating pre-restore backup..."
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    PRE_RESTORE_FILE="/tmp/${DB_NAME}_pre_restore_$TIMESTAMP.sql"
    docker exec "$CONTAINER_NAME" pg_dump -U "$DB_USER" "$DB_NAME" > "$PRE_RESTORE_FILE"
    gzip "$PRE_RESTORE_FILE"
    log "✅ Pre-restore backup saved: $PRE_RESTORE_FILE.gz"
fi

# ============================================================================
# Restore
# ============================================================================
log "🔄 Starting restore..."

# Decompress if needed
if [[ "$BACKUP_FILE" == *.gz ]]; then
    log "📦 Decompressing backup..."
    TEMP_FILE="/tmp/restore_$(date +%s).sql"
    gunzip -c "$BACKUP_FILE" > "$TEMP_FILE"
else
    TEMP_FILE="$BACKUP_FILE"
fi

# Drop and recreate database
log "🗑️  Dropping existing database..."
docker exec "$CONTAINER_NAME" psql -U "$DB_USER" -d postgres -c "DROP DATABASE IF EXISTS $DB_NAME;"

log "📝 Creating new database..."
docker exec "$CONTAINER_NAME" psql -U "$DB_USER" -d postgres -c "CREATE DATABASE $DB_NAME;"

# Restore data
log "📥 Restoring data..."
docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" < "$TEMP_FILE"

# Cleanup temp file
if [[ "$BACKUP_FILE" == *.gz ]]; then
    rm -f "$TEMP_FILE"
fi

# ============================================================================
# Summary
# ============================================================================
log "=========================================="
log "✅ Restore completed successfully!"
log "   Database: $DB_NAME"
log "   Source: $BACKUP_FILE"
log "=========================================="
