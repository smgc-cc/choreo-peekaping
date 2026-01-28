#!/bin/sh
set -e

echo "=== Peekaping for Choreo ==="
echo "Using external PostgreSQL (Supabase) and Redis (Upstash)"

# Validate required environment variables
validate_env_vars() {
    errors=0

    if [ -z "$DB_HOST" ]; then
        echo "ERROR: DB_HOST is required"
        errors=1
    fi

    if [ -z "$DB_USER" ]; then
        echo "ERROR: DB_USER is required"
        errors=1
    fi

    if [ -z "$DB_PASS" ]; then
        echo "ERROR: DB_PASS is required"
        errors=1
    fi

    if [ -z "$REDIS_HOST" ]; then
        echo "ERROR: REDIS_HOST is required"
        errors=1
    fi

    if [ $errors -eq 1 ]; then
        echo ""
        echo "Required environment variables:"
        echo "  DB_HOST, DB_USER, DB_PASS - Supabase PostgreSQL"
        echo "  REDIS_HOST - Upstash Redis"
        echo ""
        echo "Optional:"
        echo "  DB_PORT (default: 5432)"
        echo "  DB_NAME (default: postgres)"
        echo "  REDIS_PORT (default: 6379)"
        echo "  REDIS_PASSWORD"
        exit 1
    fi

    echo "Environment validation passed."
}

validate_env_vars

# Ensure /tmp directories exist (only writable location on Choreo)
mkdir -p /tmp/caddy/data /tmp/supervisor /tmp/app

# Create env.js for web app
cat >/tmp/app/env.js <<EOF
window.__CONFIG__ = { API_URL: "" };
EOF

# Export environment variables with defaults
export DB_TYPE=${DB_TYPE:-postgres}
export DB_HOST=${DB_HOST}
export DB_PORT=${DB_PORT:-5432}
export DB_NAME=${DB_NAME:-postgres}
export DB_USER=${DB_USER}
export DB_PASS=${DB_PASS}
export REDIS_HOST=${REDIS_HOST}
export REDIS_PORT=${REDIS_PORT:-6379}
export REDIS_PASSWORD=${REDIS_PASSWORD:-}
export SERVER_PORT=${SERVER_PORT:-8034}
export CLIENT_URL=${CLIENT_URL:-}
export MODE=${MODE:-prod}
export TZ=${TZ:-UTC}

echo "Configuration:"
echo "  DB: $DB_TYPE://$DB_HOST:$DB_PORT/$DB_NAME"
echo "  Redis: $REDIS_HOST:$REDIS_PORT"

# Run database migrations
echo ""
echo "Running database migrations..."
cd /app/server

if ./run-migrations.sh; then
    echo "Migrations completed!"
else
    echo "WARNING: Migration may have failed (could be already applied)"
fi

# Start supervisor
echo ""
echo "Starting services..."
exec /usr/bin/supervisord -c /app/supervisord.choreo.conf
