#!/bin/bash

# Flutter 构建脚本

set -e

echo "🚀 Starting Flutter build process..."

# 检查 Flutter 环境
echo "📱 Checking Flutter environment..."
flutter doctor -v

# 清理之前的构建
echo "🧹 Cleaning previous builds..."
flutter clean

# 获取依赖
echo "📦 Getting dependencies..."
flutter pub get

# 代码生成
echo "⚙️ Running code generation..."
dart run build_runner build --delete-conflicting-outputs

# 代码分析
echo "🔍 Analyzing code..."
flutter analyze --fatal-infos --fatal-warnings

# 格式检查
echo "🎨 Checking code formatting..."
dart format --output=none --set-exit-if-changed .

# 运行测试
echo "🧪 Running tests..."
flutter test --coverage

# 构建 APK
echo "📱 Building APK..."
flutter build apk --release

# 构建 App Bundle
echo "📦 Building App Bundle..."
flutter build appbundle --release

# 构建 iOS（如果在 macOS 上）
if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "🍎 Building iOS..."
  flutter build ios --release --no-codesign
fi

# 构建 Web
echo "🌐 Building Web..."
flutter build web --release

echo "✅ Build process completed successfully!"

# 显示构建产物信息
echo "📊 Build artifacts:"
if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
  echo "  APK: $(du -h build/app/outputs/flutter-apk/app-release.apk | cut -f1)"
fi

if [ -f "build/app/outputs/bundle/release/app-release.aab" ]; then
  echo "  App Bundle: $(du -h build/app/outputs/bundle/release/app-release.aab | cut -f1)"
fi

if [ -d "build/web" ]; then
  echo "  Web: $(du -sh build/web | cut -f1)"
fi

echo "🎉 All builds completed successfully!"