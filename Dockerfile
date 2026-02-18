# ==========================================
# 阶段 1: 构建阶段 (Builder)
# ==========================================
FROM golang:alpine AS builder

WORKDIR /src

# 安装 git
RUN apk add --no-cache git

# 1. 拉取源码
RUN git clone https://github.com/komari-monitor/komari-agent.git .

# 2. 检出最新的 Tag
RUN git fetch --tags && \
    LATEST_TAG=$(git describe --tags --abbrev=0) && \
    git checkout $LATEST_TAG

# 3. 编译并注入版本号
RUN VERSION=$(git describe --tags --always) && \
    echo "--------------------------------------" && \
    echo "正在构建版本: $VERSION" && \
    echo "--------------------------------------" && \
    go mod download && \
    CGO_ENABLED=0 go build \
    -trimpath \
    -ldflags="-s -w -X github.com/komari-monitor/komari-agent/update.CurrentVersion=${VERSION}" \
    -o komari-agent .

# ==========================================
# 第二阶段：运行环境 (Final Image)
# 基于 peekaping-bundle-sqlite:latest
# ==========================================
FROM 0xfurai/peekaping-bundle-sqlite:latest

# Fix Container (Trivy) Vulnerability Scan
USER root
RUN rm -f /etc/apt/sources.list.d/*caddy*.list \
    && apt-get update \
    && apt-get install -y --only-upgrade \
    libssl3 \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Create directories with proper ownership for user 10014
RUN mkdir -p /tmp/redis /tmp/supervisor /tmp/app /tmp/caddy \
    && chown -R 10014:10014 /app /tmp \
    && chmod -R 777 /tmp

# Copy komari-agent
COPY --from=builder /src/komari-agent /app/komari-agent

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
