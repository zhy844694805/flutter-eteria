# Eteria 部署配置指南

## 📋 概述

本文档详细说明了如何将 Eteria 应用从开发环境部署到生产环境，包括后端服务器部署和前端配置修改。

## 🔧 前端配置修改

### 1. 修改API配置

编辑 `lib/config/api_config.dart` 文件中的生产环境配置：

```dart
// 生产环境配置 - 替换为你的实际服务器域名
static const String _prodBaseUrl = 'https://your-actual-domain.com';
```

**示例配置**：
```dart
// 替换前（开发配置）
static const String _prodBaseUrl = 'https://your-domain.com';

// 替换后（生产配置）  
static const String _prodBaseUrl = 'https://api.eteria.app';
```

### 2. 验证配置

在应用启动时，配置会自动验证并打印信息（仅在开发模式下）：

```dart
// 在开发环境会看到类似输出：
🔧 [ApiConfig] Environment: Development
🔧 [ApiConfig] Platform: ios
🔧 [ApiConfig] Base URL: http://127.0.0.1:3000
🔧 [ApiConfig] API URL: http://127.0.0.1:3000/api/v1
```

### 3. 打包发布

修改配置后，重新打包应用：

```bash
# 清理构建缓存
flutter clean
flutter pub get

# Android发布包
flutter build apk --release --split-per-abi

# iOS发布包（需要在macOS上）
flutter build ios --release

# 或者构建AAB包（推荐用于Google Play）
flutter build appbundle --release
```

## 🌐 后端部署

### 1. 服务器要求

- **操作系统**: Ubuntu 20.04 LTS 或 CentOS 8
- **CPU**: 2核心以上
- **内存**: 4GB以上
- **存储**: 40GB以上 SSD
- **带宽**: 10Mbps以上

### 2. 域名和SSL

1. **购买域名**：推荐使用 `.com` 或相关顶级域名
2. **DNS解析**：将域名解析到服务器IP
3. **SSL证书**：使用 Let's Encrypt 免费证书

```bash
# 安装Certbot
sudo apt install certbot python3-certbot-nginx

# 获取SSL证书
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com

# 设置自动续期
sudo systemctl enable certbot.timer
```

### 3. 快速部署脚本

创建 `deploy.sh` 脚本：

```bash
#!/bin/bash
set -e

echo "🚀 开始部署 Eteria 后端..."

# 1. 更新系统
sudo apt update && sudo apt upgrade -y

# 2. 安装基础软件
sudo apt install -y curl wget git nginx certbot python3-certbot-nginx

# 3. 安装Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# 4. 安装PostgreSQL和Redis
sudo apt install -y postgresql postgresql-contrib redis-server
sudo systemctl start postgresql redis-server
sudo systemctl enable postgresql redis-server

# 5. 创建数据库
sudo -u postgres createdb eteria_db
sudo -u postgres createuser --pwprompt eteria_user
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE eteria_db TO eteria_user;"

# 6. 克隆项目
sudo mkdir -p /opt/eteria-backend
sudo chown $USER:$USER /opt/eteria-backend
cd /opt/eteria-backend

# 如果已存在，先备份
if [ -d "src" ]; then
    cp -r . ../eteria-backend-backup-$(date +%Y%m%d-%H%M%S)
    git pull origin main
else
    git clone <YOUR_REPOSITORY_URL> .
fi

# 7. 安装依赖并构建
npm install --production

# 8. 配置环境变量
if [ ! -f .env ]; then
    echo "请配置 .env 文件："
    echo "NODE_ENV=production"
    echo "PORT=3000"
    echo "DB_HOST=localhost"
    echo "DB_PORT=5432"  
    echo "DB_NAME=eteria_db"
    echo "DB_USER=eteria_user"
    echo "DB_PASSWORD=<YOUR_DB_PASSWORD>"
    echo "JWT_SECRET=<YOUR_JWT_SECRET>"
    echo "REDIS_HOST=localhost"
    echo "REDIS_PORT=6379"
    read -p "按回车继续编辑 .env 文件..." 
    nano .env
fi

# 9. 初始化数据库
npm run db:migrate

# 10. 安装PM2并启动服务
npm install -g pm2
pm2 start ecosystem.config.js
pm2 save
pm2 startup

# 11. 配置Nginx
read -p "请输入您的域名（如：api.yourdomain.com）: " DOMAIN
sudo tee /etc/nginx/sites-available/eteria << EOF
server {
    listen 80;
    server_name $DOMAIN;
    client_max_body_size 100M;
    
    location /uploads/ {
        alias /opt/eteria-backend/uploads/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    location /api/ {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }
    
    location /health {
        proxy_pass http://localhost:3000/health;
    }
}
EOF

sudo ln -sf /etc/nginx/sites-available/eteria /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx

# 12. 获取SSL证书
sudo certbot --nginx -d $DOMAIN

# 13. 配置防火墙
sudo ufw allow ssh
sudo ufw allow 'Nginx Full'
sudo ufw --force enable

echo "✅ 部署完成！"
echo "🌐 API地址: https://$DOMAIN"
echo "🔍 健康检查: https://$DOMAIN/health"
echo ""
echo "📋 接下来需要做的："
echo "1. 测试API接口是否正常"
echo "2. 修改前端配置文件中的API地址"
echo "3. 重新打包并发布前端应用"
```

### 4. 运行部署脚本

```bash
chmod +x deploy.sh
./deploy.sh
```

## 📱 移动应用配置

### Android配置

1. **网络权限** - 在 `android/app/src/main/AndroidManifest.xml` 中：

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

2. **网络安全配置** - 创建 `android/app/src/main/res/xml/network_security_config.xml`：

```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <domain-config cleartextTrafficPermitted="false">
        <domain includeSubdomains="true">yourdomain.com</domain>
    </domain-config>
</network-security-config>
```

3. **应用配置** - 在 `AndroidManifest.xml` 的 `application` 标签中添加：

```xml
<application
    android:networkSecurityConfig="@xml/network_security_config"
    android:usesCleartextTraffic="false">
```

### iOS配置

1. **网络权限** - 在 `ios/Runner/Info.plist` 中：

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
    <key>NSExceptionDomains</key>
    <dict>
        <key>yourdomain.com</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <false/>
            <key>NSExceptionMinimumTLSVersion</key>
            <string>TLSv1.2</string>
            <key>NSIncludesSubdomains</key>
            <true/>
        </dict>
    </dict>
</dict>
```

## 🧪 部署测试

### 1. API测试

```bash
# 健康检查
curl https://yourdomain.com/health

# 用户注册测试
curl -X POST https://yourdomain.com/api/v1/auth/send-verification-code \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com"}'

# 获取纪念列表
curl https://yourdomain.com/api/v1/memorials
```

### 2. 前端测试

1. **开发环境测试**：
```bash
flutter run --debug
# 确认连接到生产API
```

2. **发布包测试**：
```bash
flutter build apk --release
# 安装APK并测试所有功能
```

## 🔒 安全检查清单

部署完成后，请确保：

- [ ] 使用HTTPS加密所有API通信
- [ ] 数据库密码足够复杂
- [ ] JWT密钥使用256位强随机密钥
- [ ] 服务器防火墙仅开放必要端口
- [ ] 定期更新系统和依赖包
- [ ] 配置日志监控和错误报告
- [ ] 设置数据库和文件备份策略
- [ ] 配置API限流和DDoS防护

## 🚨 常见问题

### 问题1：API请求失败
**解决方案**：
1. 检查服务器防火墙设置
2. 验证SSL证书是否正常
3. 检查Nginx配置和PM2服务状态

### 问题2：CORS错误
**解决方案**：
在后端 `.env` 文件中配置正确的CORS源：
```bash
CORS_ORIGIN=https://yourdomain.com
```

### 问题3：文件上传失败
**解决方案**：
1. 检查Nginx配置的 `client_max_body_size`
2. 确认上传目录权限
3. 验证磁盘空间

### 问题4：数据库连接失败
**解决方案**：
1. 检查PostgreSQL服务状态
2. 验证数据库用户权限
3. 确认防火墙设置

## 📞 技术支持

如遇到部署问题，请：

1. 查看服务器日志：`pm2 logs eteria-backend`
2. 检查Nginx日志：`sudo tail -f /var/log/nginx/error.log`
3. 验证系统资源：`htop` 或 `pm2 monit`
4. 提交Issue并附带详细的错误信息

## 📚 相关文档

- [后端API文档](../后端/eteria-backend/README.md)
- [前端开发文档](./CLAUDE.md)
- [数据库设计文档](../后端/eteria-backend/docs/)