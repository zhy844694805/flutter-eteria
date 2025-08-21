import 'package:flutter/material.dart';
import 'dart:async';
import '../theme/app_theme.dart';
import '../theme/glassmorphism_theme.dart';
import 'platform_image.dart';

class PhotoCarousel extends StatefulWidget {
  final List<String> imagePaths;
  final List<String> imageUrls;
  final double height;
  final bool showDots;
  final bool showCounter;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final bool fullWidth; // 新增参数：是否完全填满宽度
  final bool glassStyle; // 新增参数：是否使用玻璃拟态样式

  const PhotoCarousel({
    super.key,
    this.imagePaths = const [],
    this.imageUrls = const [],
    this.height = 300,
    this.showDots = true,
    this.showCounter = true,
    this.autoPlay = false,
    this.autoPlayInterval = const Duration(seconds: 3),
    this.fullWidth = false,
    this.glassStyle = false,
  });

  @override
  State<PhotoCarousel> createState() => _PhotoCarouselState();
}

class _PhotoCarouselState extends State<PhotoCarousel> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  Timer? _autoPlayTimer;

  List<String> get allImages {
    final images = <String>[];
    images.addAll(widget.imageUrls);
    images.addAll(widget.imagePaths);
    return images;
  }

  bool get hasImages => allImages.isNotEmpty;

  @override
  void initState() {
    super.initState();
    print('📱 [PhotoCarousel] 初始化，图片数量: ${allImages.length}, autoPlay: ${widget.autoPlay}');
    print('📱 [PhotoCarousel] 图片列表: $allImages');
    _startAutoPlay();
  }

  void _startAutoPlay() {
    if (widget.autoPlay && allImages.length > 1) {
      _autoPlayTimer = Timer.periodic(widget.autoPlayInterval, (timer) {
        if (mounted && _pageController.hasClients) {
          final nextIndex = (_currentIndex + 1) % allImages.length;
          _pageController.animateToPage(
            nextIndex,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
  }

  void _resetAutoPlay() {
    _stopAutoPlay();
    _startAutoPlay();
  }

  @override
  Widget build(BuildContext context) {
    if (!hasImages) {
      return Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_not_supported,
                size: 48,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: 8),
              Text(
                '暂无照片',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    Widget pageView = PageView.builder(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      itemCount: allImages.length,
      itemBuilder: (context, index) {
        return _buildImageItem(allImages[index]);
      },
    );

    return Stack(
      children: [
        widget.fullWidth
            ? SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: pageView,
              )
            : SizedBox(height: widget.height, child: pageView),

        // 图片计数器
        if (widget.showCounter && allImages.length > 1)
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                '${_currentIndex + 1}/${allImages.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

        // 导航箭头
        if (allImages.length > 1) ...[
          // 左箭头
          Positioned(
            left: 16,
            top: 0,
            bottom: 0,
            child: Center(
              child: GestureDetector(
                onTap: _previousImage,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: widget.glassStyle
                        ? GlassmorphismColors.glassGradient
                        : null,
                    color: widget.glassStyle
                        ? null
                        : Colors.black.withValues(alpha: _currentIndex > 0 ? 0.5 : 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: widget.glassStyle
                        ? Border.all(
                            color: GlassmorphismColors.glassBorder,
                            width: 1,
                          )
                        : null,
                  ),
                  child: Icon(
                    Icons.chevron_left,
                    color: widget.glassStyle
                        ? (_currentIndex > 0
                            ? GlassmorphismColors.textPrimary
                            : GlassmorphismColors.textSecondary)
                        : Colors.white.withValues(alpha: _currentIndex > 0 ? 1.0 : 0.5),
                    size: 24,
                  ),
                ),
              ),
            ),
          ),

          // 右箭头
          Positioned(
            right: 16,
            top: 0,
            bottom: 0,
            child: Center(
              child: GestureDetector(
                onTap: _nextImage,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: widget.glassStyle
                        ? GlassmorphismColors.glassGradient
                        : null,
                    color: widget.glassStyle
                        ? null
                        : Colors.black.withValues(alpha: _currentIndex < allImages.length - 1 ? 0.5 : 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: widget.glassStyle
                        ? Border.all(
                            color: GlassmorphismColors.glassBorder,
                            width: 1,
                          )
                        : null,
                  ),
                  child: Icon(
                    Icons.chevron_right,
                    color: widget.glassStyle
                        ? (_currentIndex < allImages.length - 1
                            ? GlassmorphismColors.textPrimary
                            : GlassmorphismColors.textSecondary)
                        : Colors.white.withValues(alpha: _currentIndex < allImages.length - 1 ? 1.0 : 0.5),
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],

        // 页面指示器
        if (widget.showDots && allImages.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                allImages.length,
                (index) => _buildDot(index),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImageItem(String imagePath) {
    Widget imageWidget = PlatformImage(
      imagePath: imagePath,
      fit: BoxFit.cover,
      width: widget.fullWidth ? null : double.infinity,
      height: widget.fullWidth ? null : widget.height,
      borderRadius: widget.fullWidth ? null : BorderRadius.circular(15),
    );

    if (widget.fullWidth) {
      // 全屏模式：不添加边距，不添加圆角，完全填满容器
      return GestureDetector(
        onTap: () => _showFullScreenImage(imagePath),
        child: imageWidget,
      );
    } else {
      // 普通模式：添加边距和圆角
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: GestureDetector(
          onTap: () => _showFullScreenImage(imagePath),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: imageWidget,
          ),
        ),
      );
    }
  }

  Widget _buildDot(int index) {
    final isActive = _currentIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 12 : 8,
      height: 8,
      decoration: BoxDecoration(
        gradient: widget.glassStyle && isActive
            ? GlassmorphismColors.glassGradient
            : null,
        color: widget.glassStyle
            ? (isActive
                ? null
                : GlassmorphismColors.textSecondary.withValues(alpha: 0.5))
            : (isActive
                ? Colors.white
                : Colors.white.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(4),
        border: widget.glassStyle && isActive
            ? Border.all(
                color: GlassmorphismColors.glassBorder,
                width: 0.5,
              )
            : null,
      ),
    );
  }



  void _previousImage() {
    print('⬅️ [PhotoCarousel] 点击左箭头，当前索引: $_currentIndex');
    if (_pageController.hasClients && allImages.length > 1) {
      _resetAutoPlay();
      final targetIndex = _currentIndex > 0 ? _currentIndex - 1 : allImages.length - 1;
      print('⬅️ [PhotoCarousel] 目标索引: $targetIndex');
      _pageController.animateToPage(
        targetIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      print('⬅️ [PhotoCarousel] 无法切换：hasClients=${_pageController.hasClients}, 图片数量=${allImages.length}');
    }
  }

  void _nextImage() {
    print('➡️ [PhotoCarousel] 点击右箭头，当前索引: $_currentIndex');
    if (_pageController.hasClients && allImages.length > 1) {
      _resetAutoPlay();
      final targetIndex = _currentIndex < allImages.length - 1 ? _currentIndex + 1 : 0;
      print('➡️ [PhotoCarousel] 目标索引: $targetIndex');
      _pageController.animateToPage(
        targetIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      print('➡️ [PhotoCarousel] 无法切换：hasClients=${_pageController.hasClients}, 图片数量=${allImages.length}');
    }
  }

  void _showFullScreenImage(String imagePath) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenImageViewer(
          images: allImages,
          initialIndex: _currentIndex,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _stopAutoPlay();
    _pageController.dispose();
    super.dispose();
  }
}

class FullScreenImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const FullScreenImageViewer({
    super.key,
    required this.images,
    this.initialIndex = 0,
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '${_currentIndex + 1}/${widget.images.length}',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          final imagePath = widget.images[index];
          return InteractiveViewer(
            child: Center(
              child: PlatformImage(
                imagePath: imagePath,
                fit: BoxFit.contain,
                placeholder: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                ),
                errorWidget: const Center(
                  child: Icon(Icons.error, color: Colors.white, size: 48),
                ),
              ),
            ),
          );
        },
      ),
    );
  }


  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
