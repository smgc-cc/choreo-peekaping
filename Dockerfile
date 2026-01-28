# Dockerfile for Choreo - based on official bundle image binaries
# Extracts pre-built binaries, no rebuild needed

# Stage 1: Extract binaries from official bundle
FROM 0xfurai/peekaping-bundle-postgres:latest AS source

# Stage 2: Final lightweight image for Choreo
FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install minimal dependencies (no PostgreSQL, no Caddy)
RUN apt-get update && apt-get install -y --no-install-recommends \
    supervisor \
    netcat-openbsd \
    curl \
    ca-certificates \
    redis-server \
    nginx \
    && rm -rf /var/lib/apt/lists/*

# Create directories
RUN mkdir -p /app/server /app/web /var/log/nginx /var/lib/nginx/body \
    && chown -R 10014:10014 /var/log/nginx /var/lib/nginx

# Copy pre-built binaries from official image
COPY --from=source /app/server/api /app/server/
COPY --from=source /app/server/producer /app/server/
COPY --from=source /app/server/worker /app/server/
COPY --from=source /app/server/ingester /app/server/
COPY --from=source /app/server/bun /app/server/
COPY --from=source /app/server/cmd/bun/migrations /app/server/cmd/bun/migrations
COPY --from=source /app/server/internal/config /app/server/internal/config
COPY --from=source /app/server/run-migrations.sh /app/server/run-migrations.sh

# Copy web assets from official image
COPY --from=source /app/web /app/web

# Copy Choreo config files
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY startup.sh /app/startup.sh

# Remove default nginx config
RUN rm -f /etc/nginx/sites-enabled/default

# Set permissions
RUN chmod +x /app/startup.sh /app/server/run-migrations.sh \
    /app/server/api /app/server/producer /app/server/worker \
    /app/server/ingester /app/server/bun

# Prepare /tmp directories
RUN mkdir -p /tmp/supervisor /tmp/redis /tmp/app /tmp/nginx \
    && chmod -R 777 /tmp \
    && ln -sf /tmp/nginx /var/lib/nginx/tmp

# Choreo: run as user 10014
USER 10014

EXPOSE 8383

HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8383/api/v1/health || exit 1

CMD ["/app/startup.sh"]
