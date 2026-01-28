#!/bin/sh
set -e

echo "Starting Peekaping on Choreo..."

mkdir -p /tmp/supervisor /tmp/redis /tmp/app /tmp/nginx

# Validate required env vars
if [ -z "$DB_HOST" ] || [ -z "$DB_USER" ] || [ -z "$DB_PASS" ]; then
    echo "ERROR: DB_HOST, DB_USER, DB_PASS are required"
    exit 1
fi

# Set defaults
export DB_TYPE=${DB_TYPE:-postgres}
export DB_PORT=${DB_PORT:-5432}
export DB_NAME=${DB_NAME:-postgres}
export DB_SSL_MODE=${DB_SSL_MODE:-require}
export SERVER_PORT=${SERVER_PORT:-8034}
export CLIENT_URL=${CLIENT_URL:-}
export MODE=${MODE:-prod}
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
    timeout=$((timeout - 1))
    sleep 1
done

# Run migrations
cd /app/server
./run-migrations.sh || echo "Migration warning - continuing..."

# Start supervisor
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
