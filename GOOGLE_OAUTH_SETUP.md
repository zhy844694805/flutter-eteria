# Google OAuth 配置指南

## 📋 概述

本文档详细说明了如何配置Google OAuth登录功能，包括Google Cloud Console配置、前端配置和后端配置。

## 🔑 Google Cloud Console 配置

### 1. 创建Google Cloud项目

1. 访问 [Google Cloud Console](https://console.cloud.google.com/)
2. 点击"选择项目" → "新建项目"
3. 输入项目名称：`eteria-app`
4. 点击"创建"

### 2. 启用Google+ API

1. 在Google Cloud Console中，进入"API和服务" → "库"
2. 搜索"Google+ API"
3. 点击"Google+ API"并点击"启用"

### 3. 配置OAuth同意屏幕

1. 进入"API和服务" → "OAuth同意屏幕"
2. 选择"外部"用户类型，点击"创建"
3. 填写应用信息：
   - **应用名称**: 永念(Eteria)
   - **用户支持电子邮件**: your-email@gmail.com
   - **应用首页**: https://your-domain.com
   - **应用隐私政策链接**: https://your-domain.com/privacy
   - **应用服务条款链接**: https://your-domain.com/terms
   - **开发者联系信息**: your-email@gmail.com
4. 点击"保存并继续"

### 4. 创建OAuth 2.0客户端ID

#### Android客户端ID

1. 进入"API和服务" → "凭据"
2. 点击"创建凭据" → "OAuth客户端ID"
3. 选择应用类型：**Android**
4. 填写信息：
   - **名称**: Eteria Android
   - **软件包名称**: `com.eteria.app`（根据你的实际包名）
   - **SHA-1证书指纹**: （见下方获取方法）
5. 点击"创建"

**获取SHA-1证书指纹**：

```bash
# 开发环境（debug keystore）
keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore

# 默认密码: android
# 复制SHA1指纹，格式如: AA:AA:AA:AA:AA:AA:AA:AA:AA:AA:AA:AA:AA:AA:AA:AA:AA:AA:AA:AA

# 生产环境（release keystore）
keytool -list -v -alias your-key-alias -keystore /path/to/your/release-key.keystore
```

#### iOS客户端ID

1. 点击"创建凭据" → "OAuth客户端ID"
2. 选择应用类型：**iOS**
3. 填写信息：
   - **名称**: Eteria iOS
   - **软件包ID**: `com.eteria.app`（根据你的实际Bundle ID）
4. 点击"创建"

#### Web客户端ID（用于服务器端验证）

1. 点击"创建凭据" → "OAuth客户端ID"
2. 选择应用类型：**Web应用**
3. 填写信息：
   - **名称**: Eteria Backend
   - **已获授权的重定向URI**: `https://your-domain.com/auth/google/callback`
4. 点击"创建"

## 📱 前端配置

### 1. 下载配置文件

#### Android配置

1. 在Google Cloud Console的"凭据"页面
2. 点击Android客户端ID旁边的下载按钮
3. 下载 `google-services.json` 文件
4. 将文件放置到 `android/app/google-services.json`

#### iOS配置

1. 点击iOS客户端ID旁边的下载按钮
2. 下载 `GoogleService-Info.plist` 文件
3. 将文件放置到 `ios/Runner/GoogleService-Info.plist`

### 2. Android配置

#### `android/build.gradle`

```gradle
buildscript {
    dependencies {
        // 添加Google Services插件
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```

#### `android/app/build.gradle`

```gradle
// 在文件底部添加
apply plugin: 'com.google.gms.google-services'

android {
    defaultConfig {
        // 确保package name与Google Console中的一致
        applicationId "com.eteria.app"
    }
}

dependencies {
    // Google Sign In
    implementation 'com.google.android.gms:play-services-auth:20.7.0'
}
```

### 3. iOS配置

#### `ios/Runner/Info.plist`

在 `<dict>` 标签内添加：

```xml
<!-- Google Sign-In -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>REVERSED_CLIENT_ID</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- 替换为你的REVERSED_CLIENT_ID，在GoogleService-Info.plist中找到 -->
            <string>com.googleusercontent.apps.YOUR_REVERSED_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

### 4. Flutter配置

#### `pubspec.yaml`

```yaml
dependencies:
  google_sign_in: ^6.2.1
```

#### 更新API配置

编辑 `lib/config/api_config.dart`，确保生产环境URL正确：

```dart
static const String _prodBaseUrl = 'https://your-actual-domain.com';
```

## 🖥️ 后端配置

### 1. 安装必要依赖

```bash
cd /path/to/eteria-backend
npm install google-auth-library passport passport-google-oauth20
```

### 2. 环境变量配置

在后端 `.env` 文件中添加：

```bash
# Google OAuth配置
GOOGLE_CLIENT_ID=your-web-client-id.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-google-client-secret
GOOGLE_REDIRECT_URI=https://your-domain.com/auth/google/callback
```

### 3. 创建Google OAuth控制器

创建 `src/controllers/googleAuthController.js`：

```javascript
const { OAuth2Client } = require('google-auth-library');
const User = require('../models/User');
const jwt = require('jsonwebtoken');

const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

// Google ID令牌验证
async function verifyGoogleToken(idToken) {
  try {
    const ticket = await client.verifyIdToken({
      idToken,
      audience: process.env.GOOGLE_CLIENT_ID,
    });
    
    const payload = ticket.getPayload();
    return {
      googleId: payload['sub'],
      email: payload['email'],
      name: payload['name'],
      picture: payload['picture'],
      emailVerified: payload['email_verified'],
    };
  } catch (error) {
    throw new Error('Invalid Google ID token');
  }
}

// Google登录
async function googleSignIn(req, res) {
  try {
    const { id_token, email, name, avatar_url } = req.body;
    
    if (!id_token) {
      return res.status(400).json({
        success: false,
        message: '缺少Google ID令牌',
      });
    }

    // 验证Google ID令牌
    const googleUser = await verifyGoogleToken(id_token);
    
    // 检查邮箱是否匹配
    if (googleUser.email !== email) {
      return res.status(400).json({
        success: false,
        message: '邮箱验证失败',
      });
    }

    // 查找或创建用户
    let user = await User.findOne({ where: { email: googleUser.email } });
    
    if (!user) {
      return res.status(404).json({
        success: false,
        message: '账户不存在，请先注册',
        code: 'ACCOUNT_NOT_FOUND',
      });
    }

    // 更新Google相关信息
    await user.update({
      google_id: googleUser.googleId,
      avatar_url: avatar_url || googleUser.picture,
      is_verified: true,
    });

    // 生成JWT令牌
    const token = jwt.sign(
      { userId: user.id, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
    );

    res.json({
      success: true,
      message: 'Google登录成功',
      data: {
        user: {
          id: user.id,
          email: user.email,
          name: user.name,
          avatar_url: user.avatar_url,
          is_verified: user.is_verified,
          provider: 'google',
          created_at: user.created_at,
          updated_at: user.updated_at,
        },
        token,
        expires_in: 86400 * 7, // 7天
      },
    });
  } catch (error) {
    console.error('Google登录错误:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Google登录失败',
    });
  }
}

// Google注册
async function googleRegister(req, res) {
  try {
    const { id_token, email, name, avatar_url } = req.body;
    
    if (!id_token) {
      return res.status(400).json({
        success: false,
        message: '缺少Google ID令牌',
      });
    }

    // 验证Google ID令牌
    const googleUser = await verifyGoogleToken(id_token);
    
    // 检查邮箱是否匹配
    if (googleUser.email !== email) {
      return res.status(400).json({
        success: false,
        message: '邮箱验证失败',
      });
    }

    // 检查用户是否已存在
    const existingUser = await User.findOne({ where: { email: googleUser.email } });
    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: '该邮箱已注册，请直接登录',
        code: 'EMAIL_ALREADY_EXISTS',
      });
    }

    // 创建新用户
    const user = await User.create({
      email: googleUser.email,
      name: name || googleUser.name,
      google_id: googleUser.googleId,
      avatar_url: avatar_url || googleUser.picture,
      is_verified: true, // Google账户已验证
      provider: 'google',
    });

    // 生成JWT令牌
    const token = jwt.sign(
      { userId: user.id, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
    );

    res.status(201).json({
      success: true,
      message: 'Google注册成功',
      data: {
        user: {
          id: user.id,
          email: user.email,
          name: user.name,
          avatar_url: user.avatar_url,
          is_verified: user.is_verified,
          provider: 'google',
          created_at: user.created_at,
          updated_at: user.updated_at,
        },
        token,
        expires_in: 86400 * 7, // 7天
      },
    });
  } catch (error) {
    console.error('Google注册错误:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Google注册失败',
    });
  }
}

// 检查Google账号是否存在
async function checkGoogleAccount(req, res) {
  try {
    const { email } = req.body;
    
    if (!email) {
      return res.status(400).json({
        success: false,
        message: '缺少邮箱参数',
      });
    }

    const user = await User.findOne({ where: { email } });
    
    res.json({
      success: true,
      exists: !!user,
    });
  } catch (error) {
    console.error('检查Google账号错误:', error);
    res.status(500).json({
      success: false,
      message: '检查账号失败',
    });
  }
}

module.exports = {
  googleSignIn,
  googleRegister,
  checkGoogleAccount,
};
```

### 4. 更新用户模型

在 `src/models/User.js` 中添加Google相关字段：

```javascript
// 在用户模型中添加以下字段
google_id: {
  type: DataTypes.STRING,
  allowNull: true,
  unique: true,
},
provider: {
  type: DataTypes.ENUM('email', 'google'),
  defaultValue: 'email',
},
```

### 5. 创建路由

创建 `src/routes/googleAuth.js`：

```javascript
const express = require('express');
const router = express.Router();
const {
  googleSignIn,
  googleRegister,
  checkGoogleAccount,
} = require('../controllers/googleAuthController');

// Google登录
router.post('/signin', googleSignIn);

// Google注册
router.post('/register', googleRegister);

// 检查账号是否存在
router.post('/check', checkGoogleAccount);

module.exports = router;
```

### 6. 注册路由

在 `src/app.js` 中添加：

```javascript
// 添加Google认证路由
app.use('/api/v1/auth/google', require('./routes/googleAuth'));
```

## 🧪 测试配置

### 1. 开发环境测试

```bash
# 前端开发模式运行
flutter run --debug

# 后端开发服务器
cd /path/to/eteria-backend
npm run dev
```

### 2. 生产环境测试

```bash
# 构建发布版本
flutter build apk --release
flutter build ios --release

# 部署后端到服务器
# 按照 DEPLOYMENT.md 中的指引部署
```

## 🔍 常见问题排查

### 问题1：Android SHA-1指纹不匹配

**解决方案**：
```bash
# 重新获取正确的SHA-1指纹
keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore

# 在Google Console中更新SHA-1指纹
```

### 问题2：iOS Bundle ID不匹配

**解决方案**：
1. 检查 `ios/Runner.xcodeproj` 中的Bundle ID
2. 确保与Google Console中配置的一致
3. 更新 `GoogleService-Info.plist` 文件

### 问题3：后端Token验证失败

**解决方案**：
```bash
# 检查环境变量
echo $GOOGLE_CLIENT_ID

# 验证客户端ID是否正确（Web客户端ID）
# 确保是Web应用的客户端ID，不是Android/iOS的
```

### 问题4：CORS错误

**解决方案**：
在后端添加CORS配置：
```javascript
// 在app.js中
app.use(cors({
  origin: ['https://your-domain.com', 'http://localhost:3000'],
  credentials: true,
}));
```

## 📋 部署检查清单

部署前请确认：

- [ ] Google Cloud Console项目已创建并配置
- [ ] OAuth同意屏幕已配置
- [ ] Android/iOS/Web客户端ID已创建
- [ ] 配置文件已正确放置
- [ ] 环境变量已设置
- [ ] 后端Google OAuth接口已实现
- [ ] 前端API地址已更新为生产地址
- [ ] SHA-1指纹已更新（生产环境）
- [ ] SSL证书已配置
- [ ] DNS解析已生效

## 🔒 安全注意事项

1. **客户端密钥保护**：
   - 永远不要在前端代码中暴露Web客户端密钥
   - 移动端配置文件应该包含在应用包中，不要提交到公共代码仓库

2. **令牌验证**：
   - 后端必须验证Google ID令牌的有效性
   - 检查令牌的audience字段

3. **用户数据**：
   - 只请求必要的用户权限（email, profile）
   - 安全存储用户的Google ID

4. **域名验证**：
   - 确保重定向URI配置正确
   - 使用HTTPS进行所有Google OAuth通信

## 📞 技术支持

如遇到配置问题：

1. 查看Flutter控制台输出
2. 检查后端服务器日志
3. 验证Google Cloud Console配置
4. 确认网络连接和防火墙设置

参考文档：
- [Google Sign-In for Flutter](https://pub.dev/packages/google_sign_in)
- [Google Identity Platform](https://developers.google.com/identity)
- [OAuth 2.0 for Mobile & Desktop Apps](https://developers.google.com/identity/protocols/oauth2/native-app)