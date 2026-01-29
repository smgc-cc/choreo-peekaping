# Dockerfile for Choreo - directly based on official sqlite bundle
# Minimal changes: adapt for USER 10014, use external PostgreSQL

FROM 0xfurai/peekaping-bundle-sqlite:latest

# Fix CVE-2025-15467 (libssl3/openssl)
USER root
RUN apt-get update && apt-get install -y --only-upgrade \
    libssl3 \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Create directories with proper ownership for user 10014
# Added /tmp/app based on your previous config logic
RUN mkdir -p /tmp/redis /tmp/supervisor /tmp/app /tmp/caddy \
    && chown -R 10014:10014 /app /tmp \
    && chmod -R 777 /tmp

# Copy komari-agent
COPY --from=ghcr.io/komari-monitor/komari-agent:latest /app/komari-agent /app/komari-agent

# Copy Choreo config files (overwrite originals)
COPY Caddyfile /etc/caddy/Caddyfile
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY startup.sh /app/startup.sh

RUN chmod +x /app/startup.sh

# Choreo: run as user 10014
USER 10014

EXPOSE 8383

HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8383/api/v1/health || exit 1

CMD ["/app/startup.sh"]
