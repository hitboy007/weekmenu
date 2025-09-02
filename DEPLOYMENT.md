# 每日菜单查询系统 - 容器化部署指南

本指南将帮助您在Debian服务器上通过Docker容器部署每日菜单查询系统。

## 📋 系统要求

- **操作系统**: Debian 10+ / Ubuntu 18.04+
- **内存**: 最低 512MB，推荐 1GB+
- **存储**: 最低 2GB 可用空间
- **网络**: 需要访问互联网（用于Docker镜像下载和推送功能）

## 🚀 快速部署

### 方法一：自动部署（推荐）

1. **上传项目文件到服务器**
```bash
# 将整个项目目录上传到服务器
scp -r weekmenu/ user@your-server:/opt/
```

2. **登录服务器并执行部署脚本**
```bash
ssh user@your-server
cd /opt/weekmenu
chmod +x deploy.sh
./deploy.sh
```

部署脚本会自动：
- 检查并安装Docker和Docker Compose
- 创建必要的目录结构
- 构建Docker镜像
- 启动容器服务
- 显示访问地址和管理命令

### 方法二：手动部署

1. **安装Docker**
```bash
# 更新包索引
sudo apt-get update

# 安装必要的包
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

# 添加Docker官方GPG密钥
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# 设置稳定版仓库
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 安装Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# 启动Docker服务
sudo systemctl start docker
sudo systemctl enable docker

# 将当前用户添加到docker组
sudo usermod -aG docker $USER
```

2. **安装Docker Compose**
```bash
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

3. **部署应用**
```bash
# 进入项目目录
cd /path/to/weekmenu

# 创建数据目录
mkdir -p data

# 构建并启动容器
docker-compose up -d --build
```

## 🔧 配置说明

### 端口配置

默认配置下，应用运行在端口3000。如需修改端口，编辑 `docker-compose.yml`：

```yaml
services:
  weekmenu:
    ports:
      - "8080:80"  # 将3000改为8080
```

### 数据持久化

系统使用localStorage存储数据，但您也可以通过挂载数据目录来备份JSON文件：

```yaml
volumes:
  - ./data:/usr/share/nginx/html/data
```

### 环境变量

可以通过环境变量配置应用：

```yaml
environment:
  - NODE_ENV=production
  - TZ=Asia/Shanghai  # 设置时区
```

## 📱 推送功能配置

### 生产环境推送说明

在容器化部署中，推送功能有以下特点：

1. **浏览器依赖**: 推送服务运行在用户浏览器中，需要保持浏览器标签页打开
2. **时区设置**: 确保服务器时区正确设置
3. **网络访问**: 需要能够访问Server酱API (sctapi.ftqq.com)

### 推送服务优化建议

对于生产环境，建议考虑以下优化方案：

#### 方案一：使用cron定时任务

创建独立的推送脚本：

```bash
# 创建推送脚本
cat > /opt/weekmenu/push-cron.js << 'EOF'
// 独立的推送脚本，可以通过cron定时执行
const fs = require('fs');
const https = require('https');

// 读取用户配置和菜单数据
// 发送推送到Server酱
// ... 推送逻辑
EOF

# 添加到crontab
echo "0 8 * * * node /opt/weekmenu/push-cron.js" | crontab -
```

#### 方案二：使用GitHub Actions

在项目中添加 `.github/workflows/push.yml`，通过GitHub Actions定时推送。

## 🔍 监控和维护

### 查看容器状态
```bash
docker-compose ps
```

### 查看应用日志
```bash
docker-compose logs -f
```

### 重启服务
```bash
docker-compose restart
```

### 更新应用
```bash
# 拉取最新代码
git pull

# 重新构建并启动
docker-compose up -d --build
```

### 备份数据
```bash
# 备份localStorage数据（如果有挂载数据目录）
tar -czf weekmenu-backup-$(date +%Y%m%d).tar.gz data/

# 备份容器数据
docker exec weekmenu-app tar -czf - /usr/share/nginx/html/data > weekmenu-data-backup.tar.gz
```

## 🛡️ 安全配置

### 防火墙设置
```bash
# 只允许特定端口访问
sudo ufw allow 3000/tcp
sudo ufw enable
```

### Nginx反向代理（可选）

如果需要使用域名访问，可以配置Nginx反向代理：

```nginx
server {
    listen 80;
    server_name your-domain.com;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### SSL证书配置

使用Let's Encrypt配置HTTPS：

```bash
# 安装certbot
sudo apt-get install certbot python3-certbot-nginx

# 获取SSL证书
sudo certbot --nginx -d your-domain.com
```

## 🐛 故障排除

### 常见问题

1. **容器启动失败**
   ```bash
   # 查看详细错误日志
   docker-compose logs
   
   # 检查端口是否被占用
   sudo netstat -tlnp | grep :3000
   ```

2. **推送功能不工作**
   - 检查Server酱API Key是否正确
   - 确认网络可以访问sctapi.ftqq.com
   - 查看浏览器控制台错误信息

3. **数据丢失**
   - 检查数据目录挂载是否正确
   - 确认localStorage数据是否存在

4. **性能问题**
   ```bash
   # 查看容器资源使用情况
   docker stats weekmenu-app
   
   # 查看系统资源
   htop
   ```

### 日志位置

- **应用日志**: `docker-compose logs`
- **Nginx日志**: 容器内 `/var/log/nginx/`
- **系统日志**: `/var/log/syslog`

## 📞 技术支持

如果在部署过程中遇到问题，请：

1. 查看本文档的故障排除部分
2. 检查容器日志：`docker-compose logs`
3. 确认系统要求是否满足
4. 检查网络连接和防火墙设置

## 🔄 版本更新

当有新版本发布时：

```bash
# 停止当前服务
docker-compose down

# 拉取最新代码
git pull

# 重新构建并启动
docker-compose up -d --build

# 清理旧镜像（可选）
docker image prune -f
```

---

**部署完成后，您可以通过以下地址访问应用：**

- **首页**: http://your-server-ip:3000
- **管理后台**: http://your-server-ip:3000/admin

祝您使用愉快！🎉