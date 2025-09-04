# Eteria 开发指南

## 项目概览

Eteria (永念) 是一个纪念应用，采用 Flutter 前端和 Node.js 后端架构。本文档提供完整的开发环境设置和工作流程指南。

## 开发环境设置

### 前置要求

- **Flutter SDK**: 3.9.0+
- **Dart SDK**: 3.0.0+
- **Node.js**: 18.x+
- **PostgreSQL**: 12.x+
- **Redis**: 6.x+
- **Git**: 最新版本

### 安装依赖

#### Flutter 前端
```bash
cd /Users/tuohai/Documents/eteria
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

#### Node.js 后端
```bash
cd /Users/tuohai/Documents/后端/eteria-backend
npm install
```

### 数据库设置

1. **PostgreSQL**
   ```bash
   # 创建数据库
   createdb eteria_dev
   createdb eteria_test
   
   # 运行迁移
   cd /Users/tuohai/Documents/后端/eteria-backend
   npm run db:migrate
   npm run db:seed
   ```

2. **Redis**
   ```bash
   # 启动 Redis 服务
   redis-server
   ```

## 开发工作流

### 日常开发

1. **启动后端服务**
   ```bash
   cd /Users/tuohai/Documents/后端/eteria-backend
   npm run dev
   ```

2. **启动 Flutter 应用**
   ```bash
   cd /Users/tuohai/Documents/eteria
   flutter run --debug
   ```

### 代码质量检查

#### Flutter 前端
```bash
# 代码分析
flutter analyze --fatal-infos --fatal-warnings

# 代码格式化
dart format .

# 运行测试
flutter test --coverage

# 完整测试流程
./scripts/test.sh
```

#### Node.js 后端
```bash
# 代码检查
npm run lint
npm run lint:fix

# 代码格式化
npm run format
npm run format:check

# 运行测试
npm run test
npm run test:coverage

# 完整验证
npm run validate
```

### 构建流程

#### 开发构建
```bash
# Flutter
flutter build apk --debug
flutter run --release  # 性能测试

# 完整构建流程
./scripts/build.sh
```

#### 生产构建
```bash
# Flutter
flutter build apk --release
flutter build appbundle --release
flutter build web --release

# 后端
npm run start
```

## Git 工作流

### 提交流程

1. **功能开发**
   ```bash
   git checkout -b feature/feature-name
   # 开发功能
   git add .
   git commit -m "feat: 添加新功能"
   ```

2. **代码审查**
   ```bash
   # 自动运行 pre-commit 检查
   git push origin feature/feature-name
   # 创建 Pull Request
   ```

3. **合并代码**
   ```bash
   git checkout main
   git pull origin main
   git merge feature/feature-name
   ```

### Pre-commit 检查

Git hooks 会自动运行以下检查：
- Flutter 代码分析和格式检查
- Flutter 测试
- 后端 ESLint 检查
- 后端代码格式检查
- 后端测试

## CI/CD 流程

### GitHub Actions

项目配置了自动化 CI/CD 流程：

#### Flutter CI
- 代码分析和格式检查
- 自动化测试和覆盖率检查
- 多平台构建（Android、iOS、Web）
- 安全扫描
- 自动发布

#### Backend CI
- ESLint 代码检查
- 自动化测试
- 安全漏洞扫描
- Docker 构建和发布

### 触发条件
- `main` 和 `develop` 分支推送
- Pull Request 创建和更新
- 标签推送（自动发布）

## 测试策略

### 前端测试
- **单元测试**: 模型和工具类
- **Widget 测试**: UI 组件
- **集成测试**: 端到端流程
- **覆盖率要求**: 80%+

### 后端测试
- **单元测试**: 控制器和服务
- **API 测试**: 接口功能
- **数据库测试**: 模型和关系
- **覆盖率要求**: 80%+

### 测试命令
```bash
# 前端
flutter test --coverage
./scripts/test.sh

# 后端
npm run test:coverage
npm run test:ci
```

## Docker 开发

### 开发环境
```bash
# 启动完整开发环境
docker-compose -f docker-compose.dev.yml up

# 仅启动数据库服务
docker-compose -f docker-compose.dev.yml up postgres redis
```

### 生产部署
```bash
# 构建生产镜像
docker build -t eteria-backend ../后端/eteria-backend

# 启动生产容器
docker run -d --name eteria-backend -p 3000:3000 eteria-backend
```

## 性能优化

### Flutter 优化
- 使用 `const` 构造函数
- 实现 `dispose()` 方法
- 优化图片加载和缓存
- 使用 `Provider` 进行状态管理

### 后端优化
- 数据库查询优化
- Redis 缓存策略
- API 响应压缩
- 连接池管理

## 安全最佳实践

### 前端安全
- 输入验证和清理
- 安全的数据存储
- API 通信加密
- 敏感信息保护

### 后端安全
- JWT 令牌管理
- 输入验证中间件
- 速率限制
- SQL 注入防护
- CORS 配置

## 故障排除

### 常见问题

1. **网络连接问题**
   - iOS 模拟器使用 `127.0.0.1`
   - Android 模拟器使用 `10.0.2.2`

2. **代码生成错误**
   ```bash
   flutter clean
   flutter pub get
   dart run build_runner build --delete-conflicting-outputs
   ```

3. **数据库连接失败**
   ```bash
   # 检查服务状态
   pg_ctl status
   redis-cli ping
   
   # 重启服务
   brew services restart postgresql
   brew services restart redis
   ```

4. **端口冲突**
   ```bash
   # 查找并终止进程
   lsof -ti:3000 | xargs kill -9
   ```

### 日志和调试

#### Flutter 调试
```bash
# 启用详细日志
flutter run --verbose

# 性能调试
flutter run --profile

# 调试工具
flutter inspector
```

#### 后端调试
```bash
# 开发模式（自动重启）
npm run dev

# 调试模式
DEBUG=* npm run dev

# 日志查看
tail -f logs/app.log
```

## 代码规范

### Flutter 代码规范
- 遵循 Dart 官方样式指南
- 使用 `analysis_options.yaml` 配置
- 强制类型安全
- 详细的错误处理

### Node.js 代码规范
- ESLint 配置严格模式
- Prettier 自动格式化
- 安全性检查
- JSDoc 文档注释

## 环境配置

### 开发环境变量
```bash
# Flutter (.env)
API_BASE_URL=http://127.0.0.1:3000/api/v1
ENVIRONMENT=development

# Backend (.env)
NODE_ENV=development
DB_HOST=localhost
DB_PORT=5432
DB_NAME=eteria_dev
REDIS_HOST=localhost
REDIS_PORT=6379
JWT_SECRET=dev-secret-key
```

### 生产环境变量
```bash
# Backend (.env.production)
NODE_ENV=production
DB_HOST=prod-db-host
DB_NAME=eteria_prod
JWT_SECRET=strong-production-secret
```

## 部署流程

### 准备部署
1. 更新版本号
2. 运行完整测试套件
3. 构建生产版本
4. 安全审计

### 自动部署
- GitHub Actions 自动触发
- Docker 镜像构建
- 环境部署
- 健康检查

### 手动部署
```bash
# 前端
flutter build web --release
# 部署到 CDN

# 后端
npm run build
npm run start
# 部署到服务器
```

## 监控和维护

### 性能监控
- 应用性能指标
- 数据库查询监控
- API 响应时间
- 错误率统计

### 日志管理
- 结构化日志输出
- 错误跟踪
- 性能分析
- 审计日志

### 备份策略
- 数据库定期备份
- 代码仓库镜像
- 配置文件备份
- 恢复流程测试

## 团队协作

### 代码审查清单
- [ ] 功能完整性
- [ ] 代码质量
- [ ] 测试覆盖
- [ ] 性能影响
- [ ] 安全考虑
- [ ] 文档更新

### 发布流程
1. 功能开发和测试
2. 代码审查
3. 集成测试
4. 预发布验证
5. 生产发布
6. 监控和回滚准备

---

更多详细信息请参考 [CLAUDE.md](./CLAUDE.md) 文件。