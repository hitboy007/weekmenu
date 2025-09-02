# 多阶段构建：前端构建 + API服务 + Nginx
FROM node:18-alpine AS frontend-builder

# 设置工作目录
WORKDIR /app

# 复制前端package.json和package-lock.json
COPY frontend/package*.json ./

# 安装前端依赖
RUN npm ci

# 复制前端源代码
COPY frontend/ ./

# 设置权限并构建
RUN chmod +x node_modules/.bin/* && npm run build

# API构建阶段
FROM node:18-alpine AS api-builder

# 设置工作目录
WORKDIR /app

# 复制API package.json
COPY api/package*.json ./

# 安装API依赖（使用npm install而不是npm ci，因为可能没有package-lock.json）
RUN npm install --only=production

# 复制API源代码
COPY api/ ./

# 最终运行阶段
FROM node:18-alpine

# 安装nginx和supervisor
RUN apk add --no-cache nginx supervisor

# 创建必要的目录
RUN mkdir -p /var/log/supervisor /run/nginx

# 设置工作目录
WORKDIR /app

# 复制API代码和依赖
COPY --from=api-builder /app /app/api

# 复制前端构建结果到nginx目录
COPY --from=frontend-builder /app/dist /usr/share/nginx/html

# 创建数据目录并设置权限
RUN mkdir -p /usr/share/nginx/html/data && \
    chown -R nginx:nginx /usr/share/nginx/html

# 复制nginx配置
COPY nginx.conf /etc/nginx/nginx.conf

# 创建supervisor配置
RUN echo '[supervisord]' > /etc/supervisor/conf.d/supervisord.conf && \
    echo 'nodaemon=true' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'user=root' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo '' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo '[program:nginx]' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'command=nginx -g "daemon off;"' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'autostart=true' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'autorestart=true' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'stdout_logfile=/var/log/supervisor/nginx.log' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'stderr_logfile=/var/log/supervisor/nginx.log' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo '' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo '[program:api]' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'command=node /app/api/server.js' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'directory=/app/api' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'autostart=true' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'autorestart=true' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'stdout_logfile=/var/log/supervisor/api.log' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'stderr_logfile=/var/log/supervisor/api.log' >> /etc/supervisor/conf.d/supervisord.conf

# 暴露端口
EXPOSE 80 3001

# 启动supervisor（管理nginx和API服务）
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]