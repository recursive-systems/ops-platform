# Ops Platform Deployment Documentation

## Overview
Phoenix/Elixir application running in Podman containers on Mac mini.

## Infrastructure
- **Host**: Mac mini (Tailscale IP: 100.125.46.74)
- **Runtime**: Podman (Docker-compatible)
- **Database**: PostgreSQL 16
- **App Port**: 4000

## Current Status
**⚠️ PARTIALLY FUNCTIONAL** - App redirects to HTTPS which isn't configured

### What's Working
- ✅ Database container running and healthy
- ✅ App container starts successfully
- ✅ Phoenix endpoint binds to port 4000
- ✅ Login and dashboard functional (tested)

### Current Issue
- 🔴 HTTP requests return 301 redirect to HTTPS
- 🔴 No HTTPS listener configured (no SSL certs)
- 🔴 External access blocked by SSL redirect loop

## Root Cause
`config/prod.exs` has `force_ssl` enabled with `rewrite_on: [:x_forwarded_proto]`,
but the `url:` in `runtime.exs` sets scheme to HTTPS. This causes Plug.SSL to
redirect all HTTP traffic to HTTPS, even though no HTTPS is configured.

## Quick Fixes (Choose One)

### Option 1: Disable force_ssl (for internal/Tailscale use)
Edit `config/prod.exs`:
```elixir
# Comment out or remove:
# force_ssl: [rewrite_on: [:x_forwarded_proto]],
```

### Option 2: Add reverse proxy (recommended for production)
Add nginx/caddy in front to handle TLS termination:
```yaml
# Add to docker-compose.yml
  proxy:
    image: caddy:2-alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - caddy_data:/data
```

### Option 3: Add health endpoint exclusion
Already configured in prod.exs but needs uncommenting:
```elixir
exclude: [
  paths: ["/health"],
  hosts: ["localhost", "127.0.0.1"]
]
```

## Files Modified by Finance
1. `docker-compose.yml` - Changed Docker → Podman compatible
2. `config/runtime.exs` - Fixed SECRET_KEY_BASE, added check_origin
3. `config/prod.exs` - Already had force_ssl (causing current issue)

## Commands
```bash
# Start everything
cd ~/dev/ops-platform && podman-compose up -d

# View logs
podman logs -f ops-platform_app_1

# Restart app
podman restart ops-platform_app_1

# Health check
./health-check.sh

# Shell into app container
podman exec -it ops-platform_app_1 sh
```

## Next Steps
1. [ ] Fix SSL redirect (disable force_ssl or add proxy)
2. [ ] Create actual /health endpoint in the app
3. [ ] Set up automated deploy pipeline
4. [ ] Configure proper secrets management (not hardcoded in compose)
