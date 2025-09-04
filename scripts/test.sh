#!/bin/bash

# Flutter 测试脚本

set -e

echo "🧪 Starting Flutter testing process..."

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

# 运行单元测试
echo "🧪 Running unit tests..."
flutter test --coverage --reporter=github

# 检查测试覆盖率
echo "📊 Checking test coverage..."
if [ -f "coverage/lcov.info" ]; then
  # 计算测试覆盖率（需要安装 lcov）
  if command -v lcov &> /dev/null; then
    COVERAGE=$(lcov --summary coverage/lcov.info 2>/dev/null | grep "lines" | awk '{print $2}' | sed 's/%//')
    echo "Test coverage: $COVERAGE%"
    
    # 检查覆盖率阈值
    if (( $(echo "$COVERAGE < 80" | bc -l) )); then
      echo "❌ Test coverage is below 80%: $COVERAGE%"
      exit 1
    else
      echo "✅ Test coverage meets threshold: $COVERAGE%"
    fi
  else
    echo "⚠️ lcov not installed, skipping coverage check"
  fi
else
  echo "⚠️ Coverage file not found"
fi

# 集成测试（如果存在）
if [ -d "integration_test" ]; then
  echo "🧪 Running integration tests..."
  flutter test integration_test/
fi

# Widget 测试报告
echo "📊 Test Results Summary:"
echo "  Unit tests: Passed"
if [ -d "integration_test" ]; then
  echo "  Integration tests: Passed"
fi

echo "✅ All tests completed successfully!"