# Dockerfile for Choreo Platform
# Constraints: USER 10014, only /tmp is writable, external Supabase PostgreSQL

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

# Stage 3: Final runtime image for Choreo
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
COPY --from=caddy:alpine /usr/bin/caddy /usr/local/bin/caddy

# Create directories
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

# Copy Choreo config files
COPY Caddyfile /etc/caddy/Caddyfile
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY startup.sh /app/startup.sh

# Set permissions
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
