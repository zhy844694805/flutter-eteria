import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/glassmorphism_theme.dart';

/// 纪念数据点
class MemorialDataPoint {
  final DateTime date;
  final double value;
  final String label;

  const MemorialDataPoint({
    required this.date,
    required this.value,
    required this.label,
  });
}

/// 动态折线图组件 - 显示纪念互动趋势
class MemorialChart extends StatefulWidget {
  final List<MemorialDataPoint> data;
  final String title;
  final Color? lineColor;
  final Color? fillColor;
  final double height;
  final bool showAnimation;

  const MemorialChart({
    super.key,
    required this.data,
    required this.title,
    this.lineColor,
    this.fillColor,
    this.height = 200,
    this.showAnimation = true,
  });

  @override
  State<MemorialChart> createState() => _MemorialChartState();
}

class _MemorialChartState extends State<MemorialChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );

    if (widget.showAnimation) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      height: widget.height,
      decoration: GlassmorphismDecorations.glassCard,
      child: GlassmorphismDecorations.glassBlur(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              Expanded(
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return CustomPaint(
                      size: Size.infinite,
                      painter: ChartPainter(
                        data: widget.data,
                        lineColor: widget.lineColor ?? GlassmorphismColors.primary,
                        fillColor: widget.fillColor ?? GlassmorphismColors.primary.withValues(alpha: 0.1),
                        animationValue: widget.showAnimation ? _animation.value : 1.0,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              _buildLegend(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: GlassmorphismColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: GlassmorphismColors.glassSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: GlassmorphismColors.glassBorder,
              width: 1,
            ),
          ),
          child: Text(
            '${widget.data.length} 天',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: GlassmorphismColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    if (widget.data.isEmpty) return const SizedBox.shrink();
    
    final maxValue = widget.data.map((e) => e.value).reduce(math.max);
    final minValue = widget.data.map((e) => e.value).reduce(math.min);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildLegendItem('最小', minValue.toInt().toString(), GlassmorphismColors.textTertiary),
        _buildLegendItem('最大', maxValue.toInt().toString(), GlassmorphismColors.primary),
        _buildLegendItem('总计', widget.data.fold(0.0, (sum, item) => sum + item.value).toInt().toString(), GlassmorphismColors.secondary),
      ],
    );
  }

  Widget _buildLegendItem(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: GlassmorphismColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: GlassmorphismColors.textTertiary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: widget.height,
      decoration: GlassmorphismDecorations.glassCard,
      child: GlassmorphismDecorations.glassBlur(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.show_chart,
                size: 48,
                color: GlassmorphismColors.textTertiary,
              ),
              const SizedBox(height: 12),
              Text(
                '暂无数据',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: GlassmorphismColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 图表绘制器
class ChartPainter extends CustomPainter {
  final List<MemorialDataPoint> data;
  final Color lineColor;
  final Color fillColor;
  final double animationValue;

  ChartPainter({
    required this.data,
    required this.lineColor,
    required this.fillColor,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final pointPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    // 计算数据范围
    final maxValue = data.map((e) => e.value).reduce(math.max);
    final minValue = data.map((e) => e.value).reduce(math.min);
    final valueRange = maxValue - minValue;
    final adjustedRange = valueRange == 0 ? 1 : valueRange;

    // 创建路径点
    final path = Path();
    final fillPath = Path();
    final points = <Offset>[];

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - ((data[i].value - minValue) / adjustedRange) * size.height;
      points.add(Offset(x, y));

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        // 使用贝塞尔曲线创建平滑线条
        final prevPoint = points[i - 1];
        final controlPoint1 = Offset(prevPoint.dx + (x - prevPoint.dx) * 0.5, prevPoint.dy);
        final controlPoint2 = Offset(prevPoint.dx + (x - prevPoint.dx) * 0.5, y);
        
        path.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx, controlPoint2.dy, x, y);
        fillPath.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx, controlPoint2.dy, x, y);
      }
    }

    // 完成填充路径
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.lineTo(points.first.dx, size.height);
    fillPath.close();

    // 应用动画剪切
    final animatedWidth = size.width * animationValue;
    canvas.clipRect(Rect.fromLTWH(0, 0, animatedWidth, size.height));

    // 绘制填充区域
    canvas.drawPath(fillPath, fillPaint);

    // 绘制线条
    canvas.drawPath(path, paint);

    // 绘制数据点
    for (int i = 0; i < points.length; i++) {
      if (points[i].dx <= animatedWidth) {
        // 外圈
        canvas.drawCircle(
          points[i],
          6,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill,
        );
        // 内圈
        canvas.drawCircle(points[i], 4, pointPaint);
      }
    }

    // 绘制网格线
    _drawGrid(canvas, size);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = GlassmorphismColors.glassBorder.withValues(alpha: 0.3)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // 水平网格线
    for (int i = 0; i <= 4; i++) {
      final y = (i / 4) * size.height;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // 垂直网格线
    for (int i = 0; i <= 6; i++) {
      final x = (i / 6) * size.width;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}

/// 简化版圆环图组件
class MemorialPieChart extends StatefulWidget {
  final List<MapEntry<String, double>> data;
  final double size;
  final List<Color>? colors;

  const MemorialPieChart({
    super.key,
    required this.data,
    this.size = 120,
    this.colors,
  });

  @override
  State<MemorialPieChart> createState() => _MemorialPieChartState();
}

class _MemorialPieChartState extends State<MemorialPieChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: PieChartPainter(
              data: widget.data,
              colors: widget.colors ?? [
                GlassmorphismColors.primary,
                GlassmorphismColors.secondary,
                GlassmorphismColors.info,
                GlassmorphismColors.warning,
              ],
              animationValue: _animation.value,
            ),
          ),
        );
      },
    );
  }
}

/// 圆环图绘制器
class PieChartPainter extends CustomPainter {
  final List<MapEntry<String, double>> data;
  final List<Color> colors;
  final double animationValue;

  PieChartPainter({
    required this.data,
    required this.colors,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.8;
    final total = data.fold(0.0, (sum, entry) => sum + entry.value);

    double startAngle = -math.pi / 2;
    
    for (int i = 0; i < data.length; i++) {
      final sweepAngle = (data[i].value / total) * 2 * math.pi * animationValue;
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle / animationValue;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}