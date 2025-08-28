# Eteria Backend API

永念纪念应用后端服务，提供用户认证、纪念管理、文件上传等核心功能。

## 🚀 快速开始

### 前置要求

- Node.js 18+
- PostgreSQL 12+
- Redis 6+

### 安装步骤

1. **克隆项目**
   ```bash
   cd /Users/tuohai/Documents/后端/eteria-backend
   ```

2. **运行安装脚本**
   ```bash
   chmod +x scripts/install.sh
   ./scripts/install.sh
   ```

3. **配置环境变量**
   ```bash
   # 编辑 .env 文件，配置数据库连接等信息
   nano .env
   ```

4. **设置数据库**
   ```bash
   # 启动 PostgreSQL 和 Redis
   brew services start postgresql
   brew services start redis
   
   # 初始化数据库
   ./scripts/setup-db.sh
   ```

5. **启动服务**
   ```bash
   # 开发模式
   npm run dev
   
   # 生产模式
   npm start
   ```

## 📁 项目结构

```
src/
├── config/          # 配置文件
│   ├── database.js   # 数据库配置
│   └── redis.js      # Redis配置
├── controllers/      # 控制器
│   ├── authController.js
│   ├── userController.js
│   ├── memorialController.js
│   ├── fileController.js
│   └── aiController.js
├── middleware/       # 中间件
│   ├── auth.js       # 认证中间件
│   ├── errorHandler.js
│   ├── upload.js     # 文件上传
│   └── validate.js   # 数据验证
├── models/          # 数据模型
│   ├── User.js
│   ├── Memorial.js
│   ├── File.js
│   ├── Comment.js
│   ├── Like.js
│   └── index.js     # 模型关联
├── routes/          # 路由定义
│   ├── auth.js
│   ├── users.js
│   ├── memorials.js
│   ├── files.js
│   └── ai.js
├── services/        # 业务服务
│   └── emailService.js
├── utils/           # 工具函数
│   └── logger.js
└── app.js           # 主应用文件
```

## 🔌 API 接口

### 认证接口
- `POST /api/v1/auth/register` - 用户注册
- `POST /api/v1/auth/login` - 用户登录
- `POST /api/v1/auth/logout` - 用户登出
- `POST /api/v1/auth/refresh` - 刷新token
- `GET /api/v1/auth/me` - 获取当前用户

### 纪念管理
- `GET /api/v1/memorials` - 获取纪念列表
- `POST /api/v1/memorials` - 创建纪念
- `GET /api/v1/memorials/:id` - 获取纪念详情
- `PUT /api/v1/memorials/:id` - 更新纪念
- `DELETE /api/v1/memorials/:id` - 删除纪念

### 文件上传
- `POST /api/v1/files/upload` - 上传文件
- `POST /api/v1/files/upload-avatar` - 上传头像
- `GET /api/v1/files/:id` - 获取文件
- `DELETE /api/v1/files/:id` - 删除文件

### 互动功能
- `POST /api/v1/memorials/:id/like` - 点赞/献花
- `GET /api/v1/memorials/:id/comments` - 获取评论
- `POST /api/v1/memorials/:id/comments` - 添加评论
- `POST /api/v1/memorials/:id/view` - 增加浏览次数

## 🗄️ 数据库设计

### 主要表结构

- **users** - 用户表
- **memorials** - 纪念表  
- **files** - 文件表
- **comments** - 评论表
- **likes** - 点赞表

详细的数据库结构请参考 `src/models/` 目录下的模型文件。

## ⚙️ 环境配置

主要环境变量：

```bash
# 服务器配置
PORT=3000
NODE_ENV=development

# 数据库配置
DB_HOST=localhost
DB_PORT=5432
DB_NAME=eteria_db
DB_USER=eteria_user
DB_PASSWORD=eteria_password

# Redis配置
REDIS_HOST=localhost
REDIS_PORT=6379

# JWT配置
JWT_SECRET=your-jwt-secret
JWT_EXPIRES_IN=7d

# 邮件服务配置
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-email-password
```

## 🔧 开发命令

```bash
# 安装依赖
npm install

# 启动开发服务器
npm run dev

# 启动生产服务器
npm start

# 运行测试
npm test

# 数据库迁移
npm run db:migrate

# 初始化种子数据
npm run db:seed
```

## 🌐 部署

### 服务器部署完整指南

#### 1. 服务器准备

**推荐服务器配置**：
- CPU: 2核心以上
- 内存: 4GB以上
- 存储: 40GB以上 SSD
- 系统: Ubuntu 20.04 LTS / CentOS 8

**安装必要软件**：

```bash
# Ubuntu系统
sudo apt update
sudo apt install -y curl wget git nginx certbot python3-certbot-nginx

# 安装Node.js 18+
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# 安装PostgreSQL 14
sudo apt install -y postgresql postgresql-contrib
sudo systemctl start postgresql
sudo systemctl enable postgresql

# 安装Redis
sudo apt install -y redis-server
sudo systemctl start redis-server
sudo systemctl enable redis-server

# 安装PM2
sudo npm install -g pm2
```

#### 2. 数据库配置

```bash
# 切换到postgres用户
sudo -u postgres psql

# 创建数据库和用户
CREATE DATABASE eteria_db;
CREATE USER eteria_user WITH ENCRYPTED PASSWORD 'your_secure_password';
GRANT ALL PRIVILEGES ON DATABASE eteria_db TO eteria_user;
\q

# 验证连接
psql -h localhost -U eteria_user -d eteria_db
```

#### 3. 项目部署

```bash
# 创建部署目录
sudo mkdir -p /opt/eteria-backend
sudo chown $USER:$USER /opt/eteria-backend
cd /opt/eteria-backend

# 克隆项目（如果使用Git）
git clone <your-repository-url> .

# 或者上传代码文件到服务器
# scp -r /path/to/eteria-backend user@server:/opt/eteria-backend/

# 安装依赖
npm install --production

# 创建环境变量文件
cp .env.example .env
nano .env
```

**生产环境变量配置**：

```bash
# .env 文件内容
NODE_ENV=production
PORT=3000

# 数据库配置
DB_HOST=localhost
DB_PORT=5432
DB_NAME=eteria_db
DB_USER=eteria_user
DB_PASSWORD=your_secure_password

# Redis配置
REDIS_HOST=localhost
REDIS_PORT=6379

# JWT配置 - 使用强密钥
JWT_SECRET=your-super-secret-jwt-key-min-256-bits
JWT_EXPIRES_IN=7d

# 邮件服务配置（使用实际的SMTP服务）
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-app-password

# 文件上传路径
UPLOAD_PATH=/opt/eteria-backend/uploads

# 日志配置
LOG_LEVEL=info
LOG_FILE=/opt/eteria-backend/logs/app.log

# CORS配置（替换为实际的前端域名）
CORS_ORIGIN=https://your-domain.com
```

#### 4. 初始化数据库

```bash
# 运行数据库迁移
npm run db:migrate

# （可选）添加初始数据
npm run db:seed
```

#### 5. 使用PM2启动服务

```bash
# 创建PM2配置文件
cat > ecosystem.config.js << EOF
module.exports = {
  apps: [{
    name: 'eteria-backend',
    script: 'src/app.js',
    instances: 'max',
    exec_mode: 'cluster',
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    },
    error_file: './logs/err.log',
    out_file: './logs/out.log',
    log_file: './logs/combined.log',
    time: true,
    max_memory_restart: '1G'
  }]
};
EOF

# 启动服务
pm2 start ecosystem.config.js

# 保存PM2配置并设置开机自启
pm2 save
pm2 startup
# 按照提示执行生成的命令
```

#### 6. 配置Nginx反向代理

```bash
# 创建Nginx配置
sudo cat > /etc/nginx/sites-available/eteria << 'EOF'
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;

    # 上传文件大小限制
    client_max_body_size 100M;

    # 静态文件服务
    location /uploads/ {
        alias /opt/eteria-backend/uploads/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # API代理
    location /api/ {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }

    # 健康检查
    location /health {
        proxy_pass http://localhost:3000/health;
    }
}
EOF

# 启用站点
sudo ln -s /etc/nginx/sites-available/eteria /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

#### 7. SSL证书配置

```bash
# 使用Let's Encrypt自动配置SSL
sudo certbot --nginx -d your-domain.com -d www.your-domain.com

# 验证自动续期
sudo certbot renew --dry-run
```

#### 8. 防火墙配置

```bash
# Ubuntu UFW
sudo ufw allow ssh
sudo ufw allow 'Nginx Full'
sudo ufw --force enable

# 或者使用iptables
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT
```

#### 9. 监控和维护

```bash
# 查看服务状态
pm2 status
pm2 logs eteria-backend

# 监控系统资源
pm2 monit

# 重启服务
pm2 restart eteria-backend

# 查看Nginx日志
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

### Docker 部署（推荐用于开发）

#### 1. 创建Dockerfile

```dockerfile
# Dockerfile
FROM node:18-alpine

WORKDIR /app

# 复制package文件
COPY package*.json ./

# 安装依赖
RUN npm ci --only=production && npm cache clean --force

# 复制源码
COPY . .

# 创建非root用户
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001

# 更改文件所有权
RUN chown -R nodejs:nodejs /app
USER nodejs

EXPOSE 3000

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

CMD ["node", "src/app.js"]
```

#### 2. 创建docker-compose.yml

```yaml
version: '3.8'
services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    depends_on:
      - postgres
      - redis
    volumes:
      - ./uploads:/app/uploads
      - ./logs:/app/logs
    restart: unless-stopped

  postgres:
    image: postgres:14-alpine
    environment:
      - POSTGRES_DB=eteria_db
      - POSTGRES_USER=eteria_user
      - POSTGRES_PASSWORD=your_secure_password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./uploads:/usr/share/nginx/html/uploads
    depends_on:
      - app
    restart: unless-stopped

volumes:
  postgres_data:
  redis_data:
```

#### 3. 部署命令

```bash
# 构建并启动
docker-compose up -d

# 查看日志
docker-compose logs -f app

# 停止服务
docker-compose down
```

### 🔧 前端配置修改

部署后端到服务器后，需要修改前端的API地址：

#### 修改API客户端配置

编辑 `lib/services/api_client.dart` 文件：

```dart
class ApiClient {
  // 生产环境配置
  static String get baseUrl {
    // 开发环境
    if (kDebugMode) {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:3000/api/v1';  // Android模拟器
      } else {
        return 'http://127.0.0.1:3000/api/v1';  // iOS模拟器
      }
    }
    
    // 生产环境 - 替换为你的服务器域名
    return 'https://your-domain.com/api/v1';
  }
}
```

#### 创建环境配置文件（推荐）

创建 `lib/config/api_config.dart`：

```dart
import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _devBaseUrl = 'http://127.0.0.1:3000';
  static const String _devAndroidBaseUrl = 'http://10.0.2.2:3000';
  static const String _prodBaseUrl = 'https://your-domain.com';  // 替换为实际域名
  
  static String get baseUrl {
    if (kDebugMode) {
      // 开发环境
      return Platform.isAndroid ? _devAndroidBaseUrl : _devBaseUrl;
    } else {
      // 生产环境
      return _prodBaseUrl;
    }
  }
  
  static String get apiUrl => '$baseUrl/api/v1';
}
```

#### 打包发布配置

```bash
# Android发布包
flutter build apk --release

# iOS发布包
flutter build ios --release

# Web发布包
flutter build web --release
```

### 📋 部署检查清单

部署完成后，请验证以下项目：

- [ ] 服务器可以正常访问（ping测试）
- [ ] 数据库连接正常
- [ ] Redis连接正常  
- [ ] API健康检查正常：`curl https://your-domain.com/health`
- [ ] HTTPS证书正常
- [ ] 文件上传功能正常
- [ ] 邮件发送功能正常
- [ ] PM2服务自启动配置
- [ ] 防火墙规则配置
- [ ] 日志文件轮转配置
- [ ] 备份策略配置
- [ ] 前端API地址更新
- [ ] 移动应用重新打包测试

### 🚨 安全建议

1. **定期更新**：保持系统和依赖包的最新版本
2. **强密码**：使用复杂的数据库密码和JWT密钥
3. **备份策略**：定期备份数据库和文件
4. **日志监控**：监控异常访问和错误日志
5. **访问控制**：配置适当的防火墙规则
6. **HTTPS**：强制使用HTTPS加密传输
7. **限流**：配置API限流防止滥用

### 📱 移动应用配置

#### iOS应用配置

在 `ios/Runner/Info.plist` 中添加网络权限：

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
    <key>NSExceptionDomains</key>
    <dict>
        <key>your-domain.com</key>
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

#### Android应用配置

在 `android/app/src/main/AndroidManifest.xml` 中确保网络权限：

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

<!-- 在application标签中添加 -->
<application
    android:usesCleartextTraffic="false">
    <!-- 其他配置 -->
</application>
```

## 🚀 核心功能

当前版本包含完整的基础功能：

1. **用户系统** - 注册、登录、认证、邮箱验证
2. **纪念管理** - 创建、编辑、删除、查看纪念
3. **文件服务** - 图片/视频上传、缩略图生成
4. **社交功能** - 点赞、评论、浏览统计
5. **权限控制** - 公开/私有纪念、资源访问控制

## 🔒 安全特性

- JWT 身份认证
- 密码加密存储
- 文件类型验证
- API 限流
- 错误处理和日志记录
- 输入数据验证

## 📊 监控和日志

- 结构化日志记录
- 性能监控
- 错误追踪
- API 访问统计

## 🧪 测试

```bash
# 运行所有测试
npm test

# 运行覆盖率测试
npm run test:coverage

# 运行特定测试
npm test -- --grep "authentication"
```

## 📄 API 文档

启动服务后访问：
- 健康检查：`GET /health`
- API 基础地址：`http://localhost:3000/api/v1`

## 🤝 贡献指南

1. Fork 项目
2. 创建功能分支
3. 提交更改
4. 推送到分支
5. 创建 Pull Request

## 📞 支持

如有问题请提交 Issue 或联系开发团队。

## 📜 许可证

MIT License