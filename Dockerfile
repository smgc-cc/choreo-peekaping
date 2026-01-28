# Dockerfile for Choreo - directly based on official sqlite bundle
# Minimal changes: replace Caddy with Nginx, adapt for USER 10014, use external PostgreSQL

FROM 0xfurai/peekaping-bundle-sqlite:latest

# Install nginx, remove caddy
RUN apt-get update && apt-get install -y --no-install-recommends nginx \
    && apt-get remove -y caddy \
    && rm -rf /var/lib/apt/lists/*

# Create directories with proper ownership for user 10014
RUN mkdir -p /var/log/nginx /var/lib/nginx/body /var/lib/nginx/tmp /run /tmp/redis /tmp/supervisor /tmp/app \
    && chown -R 10014:10014 /var/log/nginx /var/lib/nginx /run /app /tmp \
    && chmod -R 777 /tmp

# Remove default nginx config
RUN rm -f /etc/nginx/sites-enabled/default

# Copy Choreo config files (overwrite originals)
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY startup.sh /app/startup.sh

RUN chmod +x /app/startup.sh

# Choreo: run as user 10014
USER 10014

EXPOSE 8383

HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8383/api/v1/health || exit 1

CMD ["/app/startup.sh"]
