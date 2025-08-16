import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'dart:math';

class EmailService {
  static const String _smtpHost = 'smtps.aruba.it';
  static const int _smtpPort = 465;
  static const String _username = 'info@aimodel.it';
  static const String _password = 'Zhyzlzxjzqg520.';
  static const String _senderName = '永念 | EternalMemory';

  static SmtpServer get _smtpServer => SmtpServer(
    _smtpHost,
    port: _smtpPort,
    ssl: true,
    username: _username,
    password: _password,
  );

  // 生成6位数验证码
  static String generateVerificationCode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  // 发送验证邮件
  static Future<bool> sendVerificationEmail({
    required String toEmail,
    required String userName,
    required String verificationCode,
  }) async {
    try {
      final message = Message()
        ..from = Address(_username, _senderName)
        ..recipients.add(toEmail)
        ..subject = '永念 - 邮箱验证码'
        ..html = _buildVerificationEmailHtml(userName, verificationCode);

      await send(message, _smtpServer);
      return true;
    } catch (e) {
      return false;
    }
  }

  // 发送欢迎邮件
  static Future<bool> sendWelcomeEmail({
    required String toEmail,
    required String userName,
  }) async {
    try {
      final message = Message()
        ..from = Address(_username, _senderName)
        ..recipients.add(toEmail)
        ..subject = '欢迎加入永念 - 让爱永恒传承'
        ..html = _buildWelcomeEmailHtml(userName);

      await send(message, _smtpServer);
      return true;
    } catch (e) {
      return false;
    }
  }

  // 发送重置密码邮件
  static Future<bool> sendPasswordResetEmail({
    required String toEmail,
    required String userName,
    required String resetCode,
  }) async {
    try {
      final message = Message()
        ..from = Address(_username, _senderName)
        ..recipients.add(toEmail)
        ..subject = '永念 - 密码重置验证码'
        ..html = _buildPasswordResetEmailHtml(userName, resetCode);

      await send(message, _smtpServer);
      return true;
    } catch (e) {
      return false;
    }
  }

  // 构建验证邮件HTML
  static String _buildVerificationEmailHtml(String userName, String code) {
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>邮箱验证</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'PingFang SC', 'Hiragino Sans GB', 'Microsoft YaHei', sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
            background-color: #F5F2ED;
        }
        .container {
            background: white;
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 4px 20px rgba(139, 125, 107, 0.1);
        }
        .header {
            text-align: center;
            margin-bottom: 30px;
        }
        .logo {
            color: #8B7D6B;
            font-size: 28px;
            font-weight: 600;
            margin-bottom: 10px;
        }
        .tagline {
            color: #666;
            font-size: 14px;
        }
        .content {
            margin: 30px 0;
        }
        .greeting {
            font-size: 18px;
            color: #333;
            margin-bottom: 20px;
        }
        .code-container {
            background: linear-gradient(135deg, #8B7D6B, #A67C5A);
            border-radius: 15px;
            padding: 30px;
            text-align: center;
            margin: 30px 0;
        }
        .code {
            font-size: 36px;
            font-weight: bold;
            color: white;
            letter-spacing: 8px;
            font-family: 'Courier New', monospace;
        }
        .code-label {
            color: rgba(255, 255, 255, 0.9);
            font-size: 14px;
            margin-top: 10px;
        }
        .notice {
            background: #FFF8E1;
            border-left: 4px solid #FFB74D;
            padding: 15px;
            margin: 20px 0;
            border-radius: 4px;
        }
        .footer {
            text-align: center;
            margin-top: 40px;
            padding-top: 30px;
            border-top: 1px solid #E5E5E5;
            color: #666;
            font-size: 12px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="logo">永念 | EternalMemory</div>
            <div class="tagline">让爱永恒传承</div>
        </div>
        
        <div class="content">
            <div class="greeting">亲爱的 $userName，您好！</div>
            
            <p>感谢您选择永念！为了确保您的账户安全，请使用以下验证码完成邮箱验证：</p>
            
            <div class="code-container">
                <div class="code">$code</div>
                <div class="code-label">验证码有效期：10分钟</div>
            </div>
            
            <div class="notice">
                <strong>安全提醒：</strong>
                <ul style="margin: 10px 0;">
                    <li>验证码请勿泄露给他人</li>
                    <li>如非本人操作，请忽略此邮件</li>
                    <li>验证码10分钟内有效</li>
                </ul>
            </div>
            
            <p>完成验证后，您就可以开始在永念中创建温馨的纪念空间，让珍贵的回忆永远传承。</p>
        </div>
        
        <div class="footer">
            <p>此邮件由系统自动发送，请勿回复</p>
            <p>© 2024 永念 | EternalMemory. 让爱永恒传承</p>
        </div>
    </div>
</body>
</html>
    ''';
  }

  // 构建欢迎邮件HTML
  static String _buildWelcomeEmailHtml(String userName) {
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>欢迎加入永念</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'PingFang SC', 'Hiragino Sans GB', 'Microsoft YaHei', sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
            background-color: #F5F2ED;
        }
        .container {
            background: white;
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 4px 20px rgba(139, 125, 107, 0.1);
        }
        .header {
            text-align: center;
            margin-bottom: 30px;
        }
        .logo {
            color: #8B7D6B;
            font-size: 28px;
            font-weight: 600;
            margin-bottom: 10px;
        }
        .welcome-banner {
            background: linear-gradient(135deg, #8B7D6B, #A67C5A);
            color: white;
            padding: 30px;
            border-radius: 15px;
            text-align: center;
            margin: 20px 0;
        }
        .welcome-title {
            font-size: 24px;
            font-weight: 600;
            margin-bottom: 10px;
        }
        .features {
            margin: 30px 0;
        }
        .feature {
            display: flex;
            margin: 20px 0;
            padding: 15px;
            background: #F9F9F9;
            border-radius: 10px;
        }
        .feature-icon {
            width: 40px;
            height: 40px;
            background: #8B7D6B;
            color: white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 15px;
            font-size: 18px;
        }
        .footer {
            text-align: center;
            margin-top: 40px;
            padding-top: 30px;
            border-top: 1px solid #E5E5E5;
            color: #666;
            font-size: 12px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="logo">永念 | EternalMemory</div>
        </div>
        
        <div class="welcome-banner">
            <div class="welcome-title">欢迎加入永念！</div>
            <div>让珍贵的回忆永恒传承</div>
        </div>
        
        <div class="content">
            <p>亲爱的 $userName，</p>
            
            <p>恭喜您成功注册永念账户！现在您可以开始创建温馨的纪念空间，保存和分享那些珍贵的回忆。</p>
            
            <div class="features">
                <div class="feature">
                    <div class="feature-icon">📸</div>
                    <div>
                        <strong>多媒体纪念</strong><br>
                        上传照片、写下文字，创建丰富的纪念内容
                    </div>
                </div>
                
                <div class="feature">
                    <div class="feature-icon">💝</div>
                    <div>
                        <strong>温馨互动</strong><br>
                        献花、留言，与亲友一起缅怀美好时光
                    </div>
                </div>
                
                <div class="feature">
                    <div class="feature-icon">🕊️</div>
                    <div>
                        <strong>永恒保存</strong><br>
                        安全可靠的云端存储，让回忆永不丢失
                    </div>
                </div>
            </div>
            
            <p>现在就开始您的永念之旅吧！</p>
        </div>
        
        <div class="footer">
            <p>此邮件由系统自动发送，请勿回复</p>
            <p>© 2024 永念 | EternalMemory. 让爱永恒传承</p>
        </div>
    </div>
</body>
</html>
    ''';
  }

  // 构建密码重置邮件HTML
  static String _buildPasswordResetEmailHtml(String userName, String code) {
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>密码重置</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'PingFang SC', 'Hiragino Sans GB', 'Microsoft YaHei', sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
            background-color: #F5F2ED;
        }
        .container {
            background: white;
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 4px 20px rgba(139, 125, 107, 0.1);
        }
        .header {
            text-align: center;
            margin-bottom: 30px;
        }
        .logo {
            color: #8B7D6B;
            font-size: 28px;
            font-weight: 600;
            margin-bottom: 10px;
        }
        .code-container {
            background: linear-gradient(135deg, #8B7D6B, #A67C5A);
            border-radius: 15px;
            padding: 30px;
            text-align: center;
            margin: 30px 0;
        }
        .code {
            font-size: 36px;
            font-weight: bold;
            color: white;
            letter-spacing: 8px;
            font-family: 'Courier New', monospace;
        }
        .warning {
            background: #FFE6E6;
            border-left: 4px solid #FF6B6B;
            padding: 15px;
            margin: 20px 0;
            border-radius: 4px;
        }
        .footer {
            text-align: center;
            margin-top: 40px;
            padding-top: 30px;
            border-top: 1px solid #E5E5E5;
            color: #666;
            font-size: 12px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="logo">永念 | EternalMemory</div>
        </div>
        
        <div class="content">
            <p>亲爱的 $userName，</p>
            
            <p>我们收到了您的密码重置请求。请使用以下验证码重置您的密码：</p>
            
            <div class="code-container">
                <div class="code">$code</div>
                <div style="color: rgba(255, 255, 255, 0.9); font-size: 14px; margin-top: 10px;">
                    验证码有效期：10分钟
                </div>
            </div>
            
            <div class="warning">
                <strong>安全提醒：</strong>
                <ul style="margin: 10px 0;">
                    <li>如果您没有请求重置密码，请忽略此邮件</li>
                    <li>请勿将验证码泄露给他人</li>
                    <li>验证码10分钟内有效</li>
                </ul>
            </div>
        </div>
        
        <div class="footer">
            <p>此邮件由系统自动发送，请勿回复</p>
            <p>© 2024 永念 | EternalMemory. 让爱永恒传承</p>
        </div>
    </div>
</body>
</html>
    ''';
  }
}