.PHONY: help install clean build test lint format dev deploy doctor

# 默认目标
help: ## 显示帮助信息
	@echo "Eteria 项目开发命令"
	@echo "==================="
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# 安装依赖
install: ## 安装前后端依赖
	@echo "📦 Installing Flutter dependencies..."
	flutter pub get
	@echo "📦 Installing Node.js dependencies..."
	cd ../后端/eteria-backend && npm install
	@echo "⚙️ Running code generation..."
	dart run build_runner build --delete-conflicting-outputs

# 清理项目
clean: ## 清理构建缓存
	@echo "🧹 Cleaning Flutter project..."
	flutter clean
	flutter pub get
	@echo "🧹 Cleaning Node.js project..."
	cd ../后端/eteria-backend && npm run clean || echo "No clean script defined"

# 代码生成
codegen: ## 运行代码生成
	@echo "⚙️ Running code generation..."
	dart run build_runner build --delete-conflicting-outputs

# 开发服务器
dev-frontend: ## 启动 Flutter 开发服务器
	@echo "🚀 Starting Flutter development server..."
	flutter run --debug

dev-backend: ## 启动后端开发服务器
	@echo "🚀 Starting backend development server..."
	cd ../后端/eteria-backend && npm run dev

dev: ## 同时启动前后端开发服务器
	@echo "🚀 Starting full development environment..."
	cd ../后端/eteria-backend && npm run dev &
	flutter run --debug

# 测试
test-frontend: ## 运行 Flutter 测试
	@echo "🧪 Running Flutter tests..."
	flutter analyze --fatal-infos --fatal-warnings
	dart format --output=none --set-exit-if-changed .
	flutter test --coverage

test-backend: ## 运行后端测试
	@echo "🧪 Running backend tests..."
	cd ../后端/eteria-backend && npm run validate

test: ## 运行所有测试
	@echo "🧪 Running all tests..."
	$(MAKE) test-frontend
	$(MAKE) test-backend

# 代码检查
lint-frontend: ## Flutter 代码检查
	@echo "🔍 Linting Flutter code..."
	flutter analyze --fatal-infos --fatal-warnings

lint-backend: ## 后端代码检查
	@echo "🔍 Linting backend code..."
	cd ../后端/eteria-backend && npm run lint

lint: ## 运行所有代码检查
	@echo "🔍 Linting all code..."
	$(MAKE) lint-frontend
	$(MAKE) lint-backend

# 代码格式化
format-frontend: ## 格式化 Flutter 代码
	@echo "🎨 Formatting Flutter code..."
	dart format .

format-backend: ## 格式化后端代码
	@echo "🎨 Formatting backend code..."
	cd ../后端/eteria-backend && npm run format

format: ## 格式化所有代码
	@echo "🎨 Formatting all code..."
	$(MAKE) format-frontend
	$(MAKE) format-backend

# 构建
build-debug: ## 构建调试版本
	@echo "🔨 Building debug version..."
	flutter build apk --debug

build-release: ## 构建发布版本
	@echo "🔨 Building release version..."
	flutter build apk --release
	flutter build appbundle --release

build-web: ## 构建 Web 版本
	@echo "🌐 Building web version..."
	flutter build web --release

build-ios: ## 构建 iOS 版本（仅 macOS）
	@echo "🍎 Building iOS version..."
	flutter build ios --release --no-codesign

build-all: ## 构建所有平台
	@echo "🔨 Building all platforms..."
	$(MAKE) build-release
	$(MAKE) build-web
	@if [ "$(shell uname)" = "Darwin" ]; then $(MAKE) build-ios; fi

# 完整构建脚本
build: ## 运行完整构建流程
	@echo "🚀 Running complete build process..."
	./scripts/build.sh

# 环境检查
doctor: ## 检查开发环境
	@echo "🔍 Checking development environment..."
	@echo "Flutter Doctor:"
	flutter doctor -v
	@echo ""
	@echo "Node.js Version:"
	node --version
	@echo ""
	@echo "npm Version:"
	npm --version
	@echo ""
	@echo "PostgreSQL Version:"
	psql --version || echo "PostgreSQL not found"
	@echo ""
	@echo "Redis Version:"
	redis-server --version || echo "Redis not found"

# 数据库操作
db-migrate: ## 运行数据库迁移
	@echo "🗄️ Running database migrations..."
	cd ../后端/eteria-backend && npm run db:migrate

db-seed: ## 填充测试数据
	@echo "🌱 Seeding database..."
	cd ../后端/eteria-backend && npm run db:seed

db-reset: ## 重置数据库
	@echo "🔄 Resetting database..."
	cd ../后端/eteria-backend && npm run db:reset

# Docker 操作
docker-build: ## 构建 Docker 镜像
	@echo "🐳 Building Docker image..."
	cd ../后端/eteria-backend && docker build -t eteria-backend .

docker-dev: ## 启动开发环境容器
	@echo "🐳 Starting development containers..."
	docker-compose -f docker-compose.dev.yml up -d

docker-stop: ## 停止所有容器
	@echo "🛑 Stopping all containers..."
	docker-compose -f docker-compose.dev.yml down

docker-logs: ## 查看容器日志
	@echo "📋 Showing container logs..."
	docker-compose -f docker-compose.dev.yml logs -f

# 部署相关
deploy-staging: ## 部署到预发布环境
	@echo "🚀 Deploying to staging..."
	# 添加预发布部署命令

deploy-production: ## 部署到生产环境
	@echo "🚀 Deploying to production..."
	# 添加生产部署命令

# 安全检查
security-check: ## 运行安全检查
	@echo "🔒 Running security checks..."
	cd ../后端/eteria-backend && npm audit --audit-level high

# 性能测试
performance-test: ## 运行性能测试
	@echo "⚡ Running performance tests..."
	flutter run --profile

# 覆盖率报告
coverage: ## 生成测试覆盖率报告
	@echo "📊 Generating coverage report..."
	flutter test --coverage
	cd ../后端/eteria-backend && npm run test:coverage

# 项目初始化
init: ## 初始化项目环境
	@echo "🚀 Initializing project..."
	$(MAKE) install
	$(MAKE) db-migrate
	$(MAKE) db-seed
	@echo "✅ Project initialized successfully!"

# 验证项目状态
verify: ## 验证项目状态
	@echo "✅ Verifying project status..."
	$(MAKE) doctor
	$(MAKE) lint
	$(MAKE) test
	@echo "✅ Project verification completed!"

# 清理并重新安装
reinstall: ## 清理并重新安装所有依赖
	@echo "🔄 Reinstalling project..."
	$(MAKE) clean
	$(MAKE) install
	@echo "✅ Project reinstalled successfully!"