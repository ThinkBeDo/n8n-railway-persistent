# 🚀 n8n Railway Deployment with Bulletproof Persistence

This repository provides a **bulletproof deployment configuration** for n8n on Railway with PostgreSQL persistence that **survives all redeployments** without data loss.

## ✨ Features

- ✅ **Persistent PostgreSQL Database** - All workflows, credentials, and executions survive redeployments  
- ✅ **Volume Mounting** - Binary data and files persist across deployments
- ✅ **Automatic Health Checks** - Railway monitors and restarts on failure
- ✅ **Security Hardened** - Basic authentication enabled by default
- ✅ **Railway Optimized** - Configured for Railway's infrastructure and port 8080
- ✅ **Backup & Restore** - Scripts for complete data backup and restoration
- ✅ **Claude API Ready** - Maintains full API access for MCP tools

## 🎯 Perfect For
- **Production n8n deployments** that need 100% uptime
- **Teams replacing local instances** with cloud-hosted solutions  
- **Developers using Claude MCP tools** for n8n workflow automation
- **Projects requiring zero data loss** on redeployments

## ⚡ Quick Deploy to Railway

1. **Fork this repository** to your GitHub account
2. **Create new Railway project** at [railway.app](https://railway.app)
3. **Connect your forked repo** to Railway
4. **Add PostgreSQL service** (Railway will auto-connect)
5. **Set required environment variables** (see below)
6. **Deploy and access** your bulletproof n8n instance!

## 🔧 Required Environment Variables

Set these in your Railway project:

```bash
# REQUIRED - Generate with: openssl rand -hex 32
N8N_ENCRYPTION_KEY=your-32-character-encryption-key-here

# REQUIRED - Your secure password
N8N_BASIC_AUTH_PASSWORD=your-secure-password-here

# REQUIRED - PostgreSQL password  
POSTGRES_PASSWORD=your-postgres-password-here

# RECOMMENDED - Basic auth username
N8N_BASIC_AUTH_USER=admin

# AUTO-SET BY RAILWAY - Webhook URLs
WEBHOOK_URL=https://${{RAILWAY_PUBLIC_DOMAIN}}
N8N_EDITOR_BASE_URL=https://${{RAILWAY_PUBLIC_DOMAIN}}
```

## 🗃️ Database Configuration

**Railway automatically configures PostgreSQL connection** through these environment variables:
- `DB_POSTGRESDB_HOST` - Railway's internal database host
- `DB_POSTGRESDB_PORT` - Database port (5432)
- `DB_POSTGRESDB_DATABASE` - Database name (n8n)
- `DB_POSTGRESDB_USER` - Database user (n8n)  
- `DB_POSTGRESDB_PASSWORD` - From your `POSTGRES_PASSWORD` variable

## 📊 Architecture Overview

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Railway       │    │    n8n App       │    │   PostgreSQL    │
│   Load Balancer │────│   Container      │────│   Service       │
│   (Port 443)    │    │   (Port 8080)    │    │   (Port 5432)   │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                              │
                       ┌──────────────────┐
                       │  Persistent      │
                       │  Volume          │
                       │  /home/node/.n8n │
                       └──────────────────┘
```

## 🔄 Data Persistence Strategy

**Two-layer persistence** ensures zero data loss:

1. **PostgreSQL Service**: Stores workflows, credentials, executions, and user data
2. **Railway Volume**: Stores binary files, logs, and configuration in `/home/node/.n8n`

Both persist across:
- ✅ Application redeployments
- ✅ Container restarts  
- ✅ Railway infrastructure updates
- ✅ Code changes and updates

## 📋 Local Development & Testing

Test your deployment locally before pushing to Railway:

```bash
# Clone your forked repository
git clone https://github.com/yourusername/n8n-railway-persistent.git
cd n8n-railway-persistent

# Copy environment template
cp .env.example .env

# Edit .env with your values
nano .env

# Start with Docker Compose
docker-compose up -d

# Access at http://localhost:8080
# Login with your N8N_BASIC_AUTH_USER/PASSWORD
```

## 💾 Backup & Restore

### Creating Backups

The included backup script creates complete snapshots:

```bash
# Manual backup
./scripts/backup-workflows.sh

# Automated daily backups (add to cron)  
0 2 * * * /app/scripts/backup-workflows.sh
```

**Backup includes:**
- Complete PostgreSQL database dump
- Exported workflows (JSON format)
- Exported credentials (encrypted)
- Compressed archive with timestamp

### Restoring from Backup

```bash
# Restore from backup file
./scripts/restore-workflows.sh backups/n8n_backup_20240803_120000.tar.gz
```

⚠️ **Warning**: Restore will replace ALL existing data!

## 🔐 Security Best Practices

1. **Strong Passwords**: Use complex passwords for all authentication
2. **Encryption Key**: Generate secure 32-character encryption key:
   ```bash
   openssl rand -hex 32
   ```  
3. **HTTPS**: Railway provides automatic HTTPS termination
4. **Network Security**: PostgreSQL uses Railway's private network
5. **Regular Backups**: Automated daily backups recommended

## 🛠️ Troubleshooting

### Container Keeps Restarting
- Check Railway logs for specific error messages
- Verify `N8N_ENCRYPTION_KEY` is exactly 32 characters  
- Ensure PostgreSQL service is running and connected

### Lost Data After Deployment
- Check that PostgreSQL service is separate (not embedded SQLite)
- Verify volume mounting is configured: `/home/node/.n8n`
- Restore from most recent backup if needed

### API Access Issues
- Confirm basic auth credentials are correct
- Check webhook URL matches Railway public domain
- Verify n8n service is healthy: `https://your-app.railway.app/healthz`

### Permission Errors  
- Container runs as `node` user (UID 1000)
- Volume permissions set automatically by Dockerfile
- Check Railway volume mount configuration

## 🔗 Claude MCP Integration

This deployment maintains full API access for Claude MCP tools:

1. **API Endpoint**: `https://your-app.railway.app/api/v1/`
2. **Authentication**: Basic auth or API key
3. **Workflows**: Full CRUD operations supported
4. **Executions**: Trigger and monitor workflow runs

Update your MCP configuration:
```json
{
  "baseURL": "https://your-app.railway.app",
  "apiKey": "your-api-key",  
  "timeout": 30000
}
```

## 📈 Monitoring & Health Checks

**Built-in monitoring:**
- Health check endpoint: `/healthz`
- Metrics endpoint: `/metrics` (when enabled)
- Railway automatic restart on failure
- PostgreSQL connection monitoring

## 💰 Cost Estimation

**Railway pricing (approximate):**
- n8n Application Service: ~$5/month
- PostgreSQL Service: ~$5/month  
- **Total**: ~$10/month for bulletproof persistence

## 🆘 Support & Documentation

- **n8n Documentation**: https://docs.n8n.io
- **Railway Documentation**: https://docs.railway.app  
- **Issues**: Create issue in this repository
- **Community**: n8n Community Forum

## 📄 License

This deployment configuration is MIT licensed. n8n itself is licensed under the [Sustainable Use License](https://github.com/n8n-io/n8n/blob/master/LICENSE.md).

---

## 🎉 Success Checklist

After deployment, verify these work:

- [ ] n8n accessible at Railway public URL
- [ ] Basic authentication working
- [ ] PostgreSQL connection established  
- [ ] Volume mounting active (`/home/node/.n8n`)
- [ ] Workflows can be created and saved
- [ ] API endpoints respond correctly
- [ ] Health check returns 200 OK
- [ ] Redeploy preserves all data
- [ ] Backup script functions properly
- [ ] Claude MCP tools can connect and control n8n

**🎯 Result**: Bulletproof n8n deployment that never loses data!
