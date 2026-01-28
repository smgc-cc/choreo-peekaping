# Dockerfile for Choreo Platform - Self-contained build from GitHub
# Constraints: USER 10014, only /tmp is writable, external Supabase PostgreSQL
# No need to fork - pulls directly from GitHub

ARG PEEKAPING_VERSION=main

# Stage 1: Build Go server binaries
FROM golang:1.24.3-alpine AS go-builder

ARG PEEKAPING_VERSION
RUN apk add --no-cache git

WORKDIR /src
RUN git clone --depth 1 --branch ${PEEKAPING_VERSION} https://github.com/0xfurai/peekaping.git .

WORKDIR /src/apps/server
RUN go mod download
RUN CGO_ENABLED=0 GOFLAGS="-trimpath" go build -o api -ldflags="-s -w" ./cmd/api
RUN CGO_ENABLED=0 GOFLAGS="-trimpath" go build -o producer -ldflags="-s -w" ./cmd/producer
RUN CGO_ENABLED=0 GOFLAGS="-trimpath" go build -o worker -ldflags="-s -w" ./cmd/worker
RUN CGO_ENABLED=0 GOFLAGS="-trimpath" go build -o ingester -ldflags="-s -w" ./cmd/ingester
RUN CGO_ENABLED=0 go build -o bun -ldflags="-s -w" ./cmd/bun

# Stage 2: Build React web app
FROM node:22-alpine AS web-builder

ARG PEEKAPING_VERSION
RUN apk add --no-cache git

WORKDIR /src
RUN git clone --depth 1 --branch ${PEEKAPING_VERSION} https://github.com/0xfurai/peekaping.git .

RUN npm install -g pnpm && pnpm install --filter=web
WORKDIR /src/apps/web
RUN pnpm run build

# Stage 3: Get Caddy binary from official image
FROM caddy:2.8-alpine AS caddy

# Stage 4: Final runtime image for Choreo
FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install minimal dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    supervisor \
    netcat-openbsd \
    curl \
    ca-certificates \
    redis-server \
    && rm -rf /var/lib/apt/lists/*

# Copy Caddy from official image
COPY --from=caddy /usr/bin/caddy /usr/local/bin/caddy

# Create app directories
RUN mkdir -p /app/server /app/web /etc/caddy

# Copy built Go binaries
COPY --from=go-builder /src/apps/server/api /app/server/
COPY --from=go-builder /src/apps/server/producer /app/server/
COPY --from=go-builder /src/apps/server/worker /app/server/
COPY --from=go-builder /src/apps/server/ingester /app/server/
COPY --from=go-builder /src/apps/server/bun /app/server/
COPY --from=go-builder /src/apps/server/cmd/bun/migrations /app/server/cmd/bun/migrations
COPY --from=go-builder /src/apps/server/internal/config /app/server/internal/config
COPY --from=go-builder /src/apps/server/scripts/run-migrations.sh /app/server/run-migrations.sh

# Copy built web assets
COPY --from=web-builder /src/apps/web/dist /app/web

# Inline Caddyfile for Choreo
RUN cat > /etc/caddy/Caddyfile <<'EOF'
{
    storage file_system /tmp/caddy/data
    admin off
}

:8383 {
    handle /api/* {
        reverse_proxy localhost:8034
    }
    handle /socket.io/* {
        reverse_proxy localhost:8034
    }
    root * /app/web
    handle /env.js {
        root * /tmp/app
        header Cache-Control "no-store, no-cache, must-revalidate, max-age=0"
        file_server
    }
    @static path *.js *.css *.mjs *.woff *.woff2 *.svg *.png *.jpg *.jpeg *.gif *.ico
    handle @static {
        header Cache-Control "public, max-age=31536000, immutable"
        file_server
    }
    handle {
        try_files {path} {path}/ /index.html
        file_server
    }
    log {
        output stdout
        format json
    }
}
EOF

# Inline supervisord config for Choreo
RUN cat > /etc/supervisor/conf.d/supervisord.conf <<'EOF'
[supervisord]
nodaemon=true
logfile=/tmp/supervisor/supervisord.log
pidfile=/tmp/supervisor/supervisord.pid
childlogdir=/tmp/supervisor

[program:redis]
command=redis-server --bind 127.0.0.1 --port 6379 --protected-mode no --dir /tmp/redis --appendonly no
autostart=true
autorestart=true
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
priority=100
startsecs=3

[program:api]
command=/app/server/api
directory=/app/server
autostart=true
autorestart=true
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
environment=REDIS_HOST="127.0.0.1",REDIS_PORT="6379",MODE="prod"
priority=200
startsecs=10

[program:producer]
command=/app/server/producer
directory=/app/server
autostart=true
autorestart=true
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
environment=REDIS_HOST="127.0.0.1",REDIS_PORT="6379",MODE="prod"
priority=210
startsecs=10

[program:worker]
command=/app/server/worker
directory=/app/server
autostart=true
autorestart=true
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
environment=REDIS_HOST="127.0.0.1",REDIS_PORT="6379",MODE="prod"
priority=220
startsecs=10

[program:ingester]
command=/app/server/ingester
directory=/app/server
autostart=true
autorestart=true
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
environment=REDIS_HOST="127.0.0.1",REDIS_PORT="6379",MODE="prod"
priority=230
startsecs=10

[program:caddy]
command=/usr/local/bin/caddy run --config /etc/caddy/Caddyfile
autostart=true
autorestart=true
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
environment=XDG_DATA_HOME="/tmp/caddy",XDG_CONFIG_HOME="/tmp/caddy"
priority=300
startsecs=5
EOF

# Inline startup script
RUN cat > /app/startup.sh <<'SCRIPT'
#!/bin/sh
set -e

echo "Starting Peekaping on Choreo..."

mkdir -p /tmp/supervisor /tmp/redis /tmp/caddy/data /tmp/app

# Validate env
if [ -z "$DB_HOST" ] || [ -z "$DB_USER" ] || [ -z "$DB_PASS" ]; then
    echo "ERROR: DB_HOST, DB_USER, DB_PASS are required"
    exit 1
fi

# Defaults
export DB_TYPE=${DB_TYPE:-postgres}
export DB_PORT=${DB_PORT:-5432}
export DB_NAME=${DB_NAME:-postgres}
export DB_SSL_MODE=${DB_SSL_MODE:-require}
export SERVER_PORT=${SERVER_PORT:-8034}
export CLIENT_URL=${CLIENT_URL:-}
export MODE=${MODE:-prod}
export REDIS_HOST=127.0.0.1
export REDIS_PORT=6379

# Create env.js
cat >/tmp/app/env.js <<EOF
window.__CONFIG__ = { API_URL: "" };
EOF

# Wait for DB
echo "Checking database connection..."
timeout=30
while [ $timeout -gt 0 ]; do
    if nc -z -w5 "$DB_HOST" "$DB_PORT" 2>/dev/null; then
        echo "Database reachable!"
        break
    fi
    timeout=$((timeout - 1))
    sleep 1
done

# Run migrations
cd /app/server
./run-migrations.sh || echo "Migration warning - continuing..."

exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
SCRIPT

RUN chmod +x /app/startup.sh /app/server/run-migrations.sh \
    /app/server/api /app/server/producer /app/server/worker \
    /app/server/ingester /app/server/bun

# Prepare /tmp directories
RUN mkdir -p /tmp/supervisor /tmp/redis /tmp/caddy /tmp/app \
    && chmod -R 777 /tmp

# Choreo: run as user 10014
USER 10014

EXPOSE 8383

HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8383/api/v1/health || exit 1

CMD ["/app/startup.sh"]
