import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/glassmorphism_theme.dart';

/// Unsplash 图片占位组件
/// 提供高质量的占位图片，专为纪念应用设计
class UnsplashImage extends StatefulWidget {
  final double width;
  final double height;
  final String? category;
  final String? keywords;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool blur;
  final int? seed; // 用于生成随机但一致的图片

  const UnsplashImage({
    super.key,
    required this.width,
    required this.height,
    this.category,
    this.keywords,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.blur = false,
    this.seed,
  });

  /// 纪念主题的预设图片
  static UnsplashImage memorial({
    required double width,
    required double height,
    BorderRadius? borderRadius,
    BoxFit fit = BoxFit.cover,
    int? seed,
  }) {
    return UnsplashImage(
      width: width,
      height: height,
      category: 'nature',
      keywords: 'peaceful,serene,flowers,garden',
      fit: fit,
      borderRadius: borderRadius,
      seed: seed,
    );
  }

  /// 头像占位图片
  static UnsplashImage avatar({
    required double size,
    int? seed,
  }) {
    return UnsplashImage(
      width: size,
      height: size,
      category: 'people',
      keywords: 'portrait,face,peaceful',
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(size / 2),
      seed: seed,
    );
  }

  /// 背景图片
  static UnsplashImage background({
    required double width,
    required double height,
    bool blur = true,
  }) {
    return UnsplashImage(
      width: width,
      height: height,
      category: 'nature',
      keywords: 'sky,clouds,peaceful,serene',
      fit: BoxFit.cover,
      blur: blur,
    );
  }

  @override
  State<UnsplashImage> createState() => _UnsplashImageState();
}

class _UnsplashImageState extends State<UnsplashImage> {
  bool _isLoading = true;
  bool _hasError = false;
  late String _imageUrl;

  @override
  void initState() {
    super.initState();
    _generateImageUrl();
  }

  void _generateImageUrl() {
    // 生成 Unsplash 图片 URL
    final width = widget.width.toInt();
    final height = widget.height.toInt();
    
    // 基础 URL
    String url = 'https://source.unsplash.com/${width}x$height';
    
    // 添加分类
    if (widget.category != null) {
      url += '/?${widget.category}';
    }
    
    // 添加关键词
    if (widget.keywords != null) {
      final separator = widget.category != null ? ',' : '/?';
      url += '$separator${widget.keywords}';
    }
    
    // 添加随机种子以获得一致的图片
    if (widget.seed != null) {
      url += '&sig=${widget.seed}';
    } else {
      // 使用当前时间戳的一部分作为种子
      final seed = DateTime.now().millisecondsSinceEpoch % 10000;
      url += '&sig=$seed';
    }
    
    _imageUrl = url;
    
    // 预加载图片
    _preloadImage();
  }

  void _preloadImage() {
    final image = NetworkImage(_imageUrl);
    final imageStream = image.resolve(const ImageConfiguration());
    
    imageStream.addListener(
      ImageStreamListener(
        (info, synchronousCall) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _hasError = false;
            });
          }
        },
        onError: (exception, stackTrace) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (_isLoading) {
      child = _buildPlaceholder();
    } else if (_hasError) {
      child = _buildErrorWidget();
    } else {
      child = _buildImage();
    }

    // 应用边框圆角
    if (widget.borderRadius != null) {
      child = ClipRRect(
        borderRadius: widget.borderRadius!,
        child: child,
      );
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: child,
    );
  }

  Widget _buildImage() {
    Widget image = Image.network(
      _imageUrl,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildPlaceholder();
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildErrorWidget();
      },
    );

    // 应用模糊效果
    if (widget.blur) {
      image = Stack(
        fit: StackFit.expand,
        children: [
          image,
          // 模糊遮罩
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  GlassmorphismColors.backgroundPrimary.withValues(alpha: 0.3),
                  GlassmorphismColors.backgroundSecondary.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return image;
  }

  Widget _buildPlaceholder() {
    if (widget.placeholder != null) {
      return widget.placeholder!;
    }

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        gradient: GlassmorphismColors.glassGradient,
        borderRadius: widget.borderRadius,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 渐变背景动画
          _buildShimmerEffect(),
          // 图标
          Icon(
            Icons.image_outlined,
            size: math.min(widget.width, widget.height) * 0.2,
            color: GlassmorphismColors.textTertiary,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    if (widget.errorWidget != null) {
      return widget.errorWidget!;
    }

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: GlassmorphismColors.backgroundSecondary,
        borderRadius: widget.borderRadius,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            size: math.min(widget.width, widget.height) * 0.2,
            color: GlassmorphismColors.textTertiary,
          ),
          const SizedBox(height: 8),
          Text(
            '图片加载失败',
            style: TextStyle(
              color: GlassmorphismColors.textTertiary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1500),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1.0 - value, -1.0 - value),
              end: Alignment(1.0 + value, 1.0 + value),
              colors: [
                GlassmorphismColors.backgroundSecondary.withValues(alpha: 0.1),
                GlassmorphismColors.backgroundPrimary.withValues(alpha: 0.3),
                GlassmorphismColors.backgroundSecondary.withValues(alpha: 0.1),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            borderRadius: widget.borderRadius,
          ),
        );
      },
      onEnd: () {
        // 重复动画
        if (mounted && _isLoading) {
          setState(() {});
        }
      },
    );
  }
}

/// Unsplash 图片网格组件
class UnsplashImageGrid extends StatelessWidget {
  final int imageCount;
  final double itemWidth;
  final double itemHeight;
  final double spacing;
  final String? category;
  final String? keywords;
  final VoidCallback? onTap;

  const UnsplashImageGrid({
    super.key,
    this.imageCount = 6,
    this.itemWidth = 120,
    this.itemHeight = 120,
    this.spacing = 8,
    this.category,
    this.keywords,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: List.generate(imageCount, (index) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: GlassmorphismDecorations.glassCard,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: UnsplashImage(
                width: itemWidth,
                height: itemHeight,
                category: category,
                keywords: keywords,
                seed: index + 1000, // 确保每张图片不同
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// 纪念主题图片选择器
class MemorialImageSelector extends StatefulWidget {
  final Function(String)? onImageSelected;
  final String? selectedImageUrl;

  const MemorialImageSelector({
    super.key,
    this.onImageSelected,
    this.selectedImageUrl,
  });

  @override
  State<MemorialImageSelector> createState() => _MemorialImageSelectorState();
}

class _MemorialImageSelectorState extends State<MemorialImageSelector> {
  String? _selectedUrl;
  final List<String> _categories = [
    'nature',
    'flowers',
    'peaceful',
    'serene',
    'garden',
    'sky',
  ];

  @override
  void initState() {
    super.initState();
    _selectedUrl = widget.selectedImageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: GlassmorphismDecorations.glassCard,
      child: GlassmorphismDecorations.glassBlur(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '选择纪念图片',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: GlassmorphismColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.builder(
                  scrollDirection: Axis.horizontal,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    childAspectRatio: 1,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final imageUrl = 'https://source.unsplash.com/150x150/?$category&sig=${index + 2000}';
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedUrl = imageUrl;
                        });
                        widget.onImageSelected?.call(imageUrl);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: _selectedUrl == imageUrl
                              ? Border.all(
                                  color: GlassmorphismColors.primary,
                                  width: 2,
                                )
                              : Border.all(
                                  color: GlassmorphismColors.glassBorder,
                                  width: 1,
                                ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: UnsplashImage(
                            width: 120,
                            height: 120,
                            category: category,
                            seed: index + 2000,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}