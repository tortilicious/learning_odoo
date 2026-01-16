# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Docker-based development environment for Odoo ERP with PostgreSQL. Uses Docker Compose for orchestration with automatic database initialization and admin credential configuration.

## Common Commands

```bash
# Start services (first run initializes DB and admin user)
docker compose up -d

# View logs
docker compose logs -f odoo       # Odoo logs
docker compose logs -f db         # PostgreSQL logs

# Restart Odoo (required after Python code changes)
docker compose restart odoo

# Access container shells
docker compose exec odoo bash
docker compose exec db psql -U odoo -d odoo

# Full reset (deletes all data)
docker compose down -v && docker compose up -d
```

## Architecture

**Services (docker-compose.yml):**
- `db`: PostgreSQL database (image version via `$POSTGRES_IMAGE`)
- `odoo`: Odoo application server (image version via `$ODOO_IMAGE`)

**Key Files:**
- `entrypoint.sh`: Custom entrypoint that handles first-run initialization (installs base module, sets admin credentials) and auto-updates modules listed in `$ODOO_DEV_MODULES`
- `odoo.conf`: Odoo configuration with dev mode enabled (`dev_mode = xml,reload,qweb`)
- `.env`: Environment variables for credentials and image versions (copy from `.env.example`)

**Volume Mounts:**
- `./addons` → `/mnt/extra-addons`: Custom Odoo modules
- `./odoo.conf` → `/etc/odoo/odoo.conf`: Configuration file
- `./entrypoint.sh` → `/entrypoint.sh`: Initialization script

## Development Workflow

**Module Development:**
1. Create modules in `addons/` directory (each module needs `__init__.py` and `__manifest__.py`)
2. XML changes are hot-reloaded (dev mode enabled)
3. Python changes require `docker compose restart odoo`
4. To auto-update specific modules on restart, set `ODOO_DEV_MODULES=module1,module2` in `.env`

**Database Access:**
- PostgreSQL exposed on port 5432 for external tools
- Connect with: `psql -h localhost -U odoo -d odoo`

**Odoo Access:**
- Web interface: `http://localhost:8069` (or port set in `$ODOO_PORT`)
- XML-RPC enabled for external integrations

## Configuration Notes

- Admin credentials (`ODOO_ADMIN_EMAIL`, `ODOO_ADMIN_PASSWORD`) only apply on first initialization
- `admin_passwd` in odoo.conf is the master password for database management UI
- Demo data disabled by default (`without_demo = all`)
