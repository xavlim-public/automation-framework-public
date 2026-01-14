#!/bin/bash
#
# Database Backup Script
# Creates timestamped, compressed PostgreSQL backups with retention policy
#
set -euo pipefail

# ============================================================================
# Configuration
# ============================================================================
BACKUP_DIR="${BACKUP_DIR:-/backups}"
CONTAINER_NAME="${DB_CONTAINER:-db}"
DB_USER="${POSTGRES_USER:-user}"
DB_NAME="${POSTGRES_DB:-app}"
RETENTION_DAYS="${RETENTION_DAYS:-7}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_$TIMESTAMP.sql"

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

# ============================================================================
# Pre-flight checks
# ============================================================================
log "🔍 Running pre-flight checks..."

# Check if backup directory exists
if [[ ! -d "$BACKUP_DIR" ]]; then
    log "📁 Creating backup directory: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
fi

# Check if container is running
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    error "Container '$CONTAINER_NAME' is not running"
fi

# ============================================================================
# Backup
# ============================================================================
log "📸 Starting backup..."
log "   Database: $DB_NAME"
log "   Container: $CONTAINER_NAME"
log "   Output: $BACKUP_FILE.gz"

# Create backup
if docker exec "$CONTAINER_NAME" pg_dump -U "$DB_USER" "$DB_NAME" > "$BACKUP_FILE"; then
    log "✅ Database dump completed"
else
    error "Failed to create database dump"
fi

# Compress backup
log "🗜️  Compressing backup..."
if gzip "$BACKUP_FILE"; then
    log "✅ Compression completed"
else
    error "Failed to compress backup"
fi

# Get file size
BACKUP_SIZE=$(du -h "$BACKUP_FILE.gz" | cut -f1)
log "📦 Backup size: $BACKUP_SIZE"

# ============================================================================
# Cleanup old backups
# ============================================================================
log "🧹 Cleaning up backups older than $RETENTION_DAYS days..."
DELETED_COUNT=$(find "$BACKUP_DIR" -name "${DB_NAME}_*.sql.gz" -mtime +$RETENTION_DAYS -delete -print | wc -l)
log "   Deleted $DELETED_COUNT old backup(s)"

# ============================================================================
# Summary
# ============================================================================
log "=========================================="
log "✅ Backup completed successfully!"
log "   File: $BACKUP_FILE.gz"
log "   Size: $BACKUP_SIZE"
log "=========================================="
