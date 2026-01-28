# 基于官方镜像，适配 Choreo 平台
# 无需 fork，无需重新编译
FROM 0xfurai/peekaping-bundle-postgres:latest

# 复制 Choreo 专用配置
COPY Caddyfile.choreo /app/Caddyfile.choreo
COPY supervisord.choreo.conf /app/supervisord.choreo.conf
COPY startup.choreo.sh /app/startup.choreo.sh

# 设置权限
RUN chmod +x /app/startup.choreo.sh

# 切换到 Choreo 要求的用户
USER 10014

# Choreo 标准端口
EXPOSE 8080

WORKDIR /app

CMD ["/app/startup.choreo.sh"]
