#!/bin/sh
set -e

# Komari agent env
KOMARI_SERVER="${KOMARI_SERVER:-}"
KOMARI_SECRET="${KOMARI_SECRET:-}"

echo "Starting Peekaping on Choreo..."

# Create tmp directories
mkdir -p /tmp/supervisor /tmp/redis /tmp/app /tmp/caddy/data

# Validate required env vars
if [ -z "$DB_HOST" ] || [ -z "$DB_USER" ] || [ -z "$DB_PASS" ]; then
    echo "ERROR: DB_HOST, DB_USER, DB_PASS are required"
    exit 1
fi

# Set database config for external PostgreSQL (Supabase)
export DB_TYPE=${DB_TYPE:-postgres}
export DB_HOST=${DB_HOST}
export DB_PORT=${DB_PORT:-5432}
export DB_NAME=${DB_NAME:-postgres}
export DB_USER=${DB_USER}
export DB_PASS=${DB_PASS}
export DB_SSL_MODE=${DB_SSL_MODE:-require}

# Server config
export SERVER_PORT=${SERVER_PORT:-8034}
export CLIENT_URL=${CLIENT_URL:-}
export MODE=${MODE:-prod}
export TZ=${TZ:-UTC}

# Redis config (local)
export REDIS_HOST=127.0.0.1
export REDIS_PORT=6379

# Create env.js for web app
echo 'window.__CONFIG__ = { API_URL: "" };' > /tmp/app/env.js

# Wait for database
echo "Checking database connection..."
timeout=30
while [ $timeout -gt 0 ]; do
    if nc -z -w5 "$DB_HOST" "$DB_PORT" 2>/dev/null; then
        echo "Database reachable!"
        break
    fi
    echo "Waiting for database... ($timeout)"
    timeout=$((timeout - 1))
    sleep 1
done

# Run migrations
echo "Running database migrations..."
cd /app/server
./run-migrations.sh || echo "Migration warning - continuing..."

# Start supervisor
echo "Starting services..."
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
