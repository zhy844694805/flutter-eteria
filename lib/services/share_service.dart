import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/memorial.dart';
import '../theme/glassmorphism_theme.dart';

/// 分享服务类 - 处理分享链接、海报图、二维码等功能
class ShareService {
  static const String _baseUrl = 'https://eteria.app'; // 替换为实际域名
  
  /// 生成纪念页面分享链接
  static String generateMemorialUrl(int memorialId) {
    return '$_baseUrl/memorial/$memorialId';
  }
  
  /// 复制链接到剪贴板
  static Future<bool> copyLinkToClipboard(Memorial memorial) async {
    try {
      final url = generateMemorialUrl(memorial.id);
      await Clipboard.setData(ClipboardData(text: url));
      print('📋 [ShareService] 链接已复制到剪贴板: $url');
      return true;
    } catch (e) {
      print('❌ [ShareService] 复制链接失败: $e');
      return false;
    }
  }
  
  /// 生成二维码数据
  static Widget generateQRCode(Memorial memorial, {double size = 200}) {
    final url = generateMemorialUrl(memorial.id);
    
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: QrImageView(
              data: url,
              version: QrVersions.auto,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.all(8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '扫码缅怀 ${memorial.name}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  /// 生成并分享二维码图片 (简化版)
  static Future<bool> shareQRCode(Memorial memorial, BuildContext context) async {
    try {
      // 简化实现：直接分享二维码URL
      final url = generateMemorialUrl(memorial.id);
      await Share.share(
        '扫码查看 ${memorial.name} 的纪念页面：$url\n\n您也可以在浏览器中访问此链接。',
        subject: '${memorial.name} 的纪念页面二维码',
      );
      return true;
    } catch (e) {
      print('❌ [ShareService] 分享二维码失败: $e');
      return false;
    }
  }
  
  /// 生成纪念海报
  static Widget generateMemorialPoster(Memorial memorial, {double width = 400, double height = 600}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            GlassmorphismColors.backgroundPrimary,
            GlassmorphismColors.backgroundSecondary,
            GlassmorphismColors.backgroundTertiary,
          ],
        ),
      ),
      child: Column(
        children: [
          // 头部区域
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Logo和标题
                Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      color: GlassmorphismColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '永念',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: GlassmorphismColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // 纪念者信息
                Text(
                  memorial.name,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: GlassmorphismColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (memorial.relationship?.isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  Text(
                    '我的${memorial.relationship}',
                    style: TextStyle(
                      fontSize: 16,
                      color: GlassmorphismColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
          
          // 图片区域
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: GlassmorphismColors.glassBorder,
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: memorial.primaryImage != null
                    ? Image.network(
                        memorial.primaryImage!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: GlassmorphismColors.backgroundSecondary,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.photo,
                                    size: 48,
                                    color: GlassmorphismColors.textTertiary,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '珍贵的回忆',
                                    style: TextStyle(
                                      color: GlassmorphismColors.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: GlassmorphismColors.backgroundSecondary,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.photo,
                                size: 48,
                                color: GlassmorphismColors.textTertiary,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '珍贵的回忆',
                                style: TextStyle(
                                  color: GlassmorphismColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
          ),
          
          // 时间信息
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  '${memorial.birthDate.year} - ${memorial.deathDate.year}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: GlassmorphismColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '享年 ${memorial.deathDate.year - memorial.birthDate.year} 岁',
                  style: TextStyle(
                    fontSize: 14,
                    color: GlassmorphismColors.textSecondary,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 二维码
                Container(
                  width: 120,
                  height: 120,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: QrImageView(
                    data: generateMemorialUrl(memorial.id),
                    version: QrVersions.auto,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  '扫码查看完整纪念',
                  style: TextStyle(
                    fontSize: 12,
                    color: GlassmorphismColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// 生成并分享海报图片 (简化版)
  static Future<bool> shareMemorialPoster(Memorial memorial, BuildContext context) async {
    try {
      // 简化实现：分享纪念信息文本
      final url = generateMemorialUrl(memorial.id);
      final birthYear = memorial.birthDate.year;
      final deathYear = memorial.deathDate.year;
      final age = deathYear - birthYear;
      
      final posterText = '''
【永念 - 纪念海报】

${memorial.name}
${memorial.relationship?.isNotEmpty == true ? '我的${memorial.relationship}' : ''}

$birthYear - $deathYear (享年 $age 岁)

愿您在天堂安好，我们永远怀念您。

查看完整纪念页面：$url
      '''.trim();
      
      await Share.share(
        posterText,
        subject: '${memorial.name} 的纪念海报',
      );
      return true;
    } catch (e) {
      print('❌ [ShareService] 分享海报失败: $e');
      return false;
    }
  }
  
  /// 分享纪念链接
  static Future<bool> shareMemorialLink(Memorial memorial) async {
    try {
      final url = generateMemorialUrl(memorial.id);
      await Share.share(
        '我想与您分享 ${memorial.name} 的纪念页面，点击链接查看：$url',
        subject: '${memorial.name} 的纪念页面',
      );
      return true;
    } catch (e) {
      print('❌ [ShareService] 分享链接失败: $e');
      return false;
    }
  }
  
  /// 在浏览器中打开链接
  static Future<bool> openInBrowser(Memorial memorial) async {
    try {
      final url = generateMemorialUrl(memorial.id);
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }
      return false;
    } catch (e) {
      print('❌ [ShareService] 打开浏览器失败: $e');
      return false;
    }
  }
  
}