#!/bin/bash

# n8n Workflow Backup Script for Railway
# This script backs up workflows, credentials, and settings from PostgreSQL

set -e

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
BACKUP_DIR="${BACKUP_DIR:-./backups}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="n8n_backup_${TIMESTAMP}"

# Database configuration (from environment or defaults)
DB_HOST="${DB_POSTGRESDB_HOST:-localhost}"
DB_PORT="${DB_POSTGRESDB_PORT:-5432}"
DB_NAME="${DB_POSTGRESDB_DATABASE:-n8n}"
DB_USER="${DB_POSTGRESDB_USER:-n8n}"
DB_PASS="${DB_POSTGRESDB_PASSWORD:-n8n}"

# Create backup directory
mkdir -p "${BACKUP_DIR}"

echo -e "${GREEN}Starting n8n backup...${NC}"
echo "Backup name: ${BACKUP_NAME}"

# Export PostgreSQL connection string
export PGPASSWORD="${DB_PASS}"

# Create SQL dump of n8n database
echo -e "${YELLOW}Backing up database...${NC}"
pg_dump -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" -d "${DB_NAME}" \
    --no-owner --no-acl --clean --if-exists \
    > "${BACKUP_DIR}/${BACKUP_NAME}.sql"

# Create a JSON export of workflows (optional - requires n8n CLI)
if command -v n8n &> /dev/null; then
    echo -e "${YELLOW}Exporting workflows to JSON...${NC}"
    mkdir -p "${BACKUP_DIR}/${BACKUP_NAME}_workflows"
    n8n export:workflow --all --output="${BACKUP_DIR}/${BACKUP_NAME}_workflows"
    n8n export:credentials --all --output="${BACKUP_DIR}/${BACKUP_NAME}_credentials"
fi

# Compress the backup
echo -e "${YELLOW}Compressing backup...${NC}"
cd "${BACKUP_DIR}"
tar -czf "${BACKUP_NAME}.tar.gz" "${BACKUP_NAME}.sql" "${BACKUP_NAME}_workflows" "${BACKUP_NAME}_credentials" 2>/dev/null || \
tar -czf "${BACKUP_NAME}.tar.gz" "${BACKUP_NAME}.sql" 2>/dev/null

# Clean up uncompressed files
rm -f "${BACKUP_NAME}.sql"
rm -rf "${BACKUP_NAME}_workflows" "${BACKUP_NAME}_credentials" 2>/dev/null || true

# Keep only last 7 backups
echo -e "${YELLOW}Cleaning old backups...${NC}"
ls -t *.tar.gz 2>/dev/null | tail -n +8 | xargs -r rm -f

echo -e "${GREEN}Backup completed successfully!${NC}"
echo "Backup saved to: ${BACKUP_DIR}/${BACKUP_NAME}.tar.gz"

# Upload to cloud storage (optional - add your own implementation)
# Example: aws s3 cp "${BACKUP_DIR}/${BACKUP_NAME}.tar.gz" s3://your-bucket/n8n-backups/
