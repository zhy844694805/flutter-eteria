import 'package:flutter/material.dart';

class StaggeredGridView extends StatelessWidget {
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final List<Widget> children;

  const StaggeredGridView({
    super.key,
    required this.crossAxisCount,
    required this.mainAxisSpacing,
    required this.crossAxisSpacing,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 
            ((crossAxisCount - 1) * crossAxisSpacing)) / crossAxisCount;
        
        return _StaggeredGridViewWidget(
          itemWidth: itemWidth,
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          children: children,
        );
      },
    );
  }
}

class _StaggeredGridViewWidget extends StatefulWidget {
  final double itemWidth;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final List<Widget> children;

  const _StaggeredGridViewWidget({
    required this.itemWidth,
    required this.crossAxisCount,
    required this.mainAxisSpacing,
    required this.crossAxisSpacing,
    required this.children,
  });

  @override
  State<_StaggeredGridViewWidget> createState() => _StaggeredGridViewWidgetState();
}

class _StaggeredGridViewWidgetState extends State<_StaggeredGridViewWidget> {
  final List<GlobalKey> _keys = [];
  final List<double> _columnHeights = [];
  final List<List<int>> _columnItems = [];

  @override
  void initState() {
    super.initState();
    _initializeColumns();
    _generateKeys();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureAndArrange();
    });
  }

  void _initializeColumns() {
    _columnHeights.clear();
    _columnItems.clear();
    for (int i = 0; i < widget.crossAxisCount; i++) {
      _columnHeights.add(0);
      _columnItems.add([]);
    }
  }

  void _generateKeys() {
    _keys.clear();
    for (int i = 0; i < widget.children.length; i++) {
      _keys.add(GlobalKey());
    }
  }

  void _measureAndArrange() {
    _initializeColumns();
    
    for (int i = 0; i < widget.children.length; i++) {
      final renderBox = _keys[i].currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final height = renderBox.size.height;
        
        // 找到高度最小的列
        int shortestColumnIndex = 0;
        double shortestHeight = _columnHeights[0];
        
        for (int j = 1; j < _columnHeights.length; j++) {
          if (_columnHeights[j] < shortestHeight) {
            shortestHeight = _columnHeights[j];
            shortestColumnIndex = j;
          }
        }
        
        // 将item添加到最短的列
        _columnItems[shortestColumnIndex].add(i);
        _columnHeights[shortestColumnIndex] += height + widget.mainAxisSpacing;
      }
    }
    
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_keys.isEmpty || _keys.length != widget.children.length) {
      return _buildMeasureWidget();
    }

    if (_columnItems.every((column) => column.isEmpty)) {
      return _buildMeasureWidget();
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(widget.crossAxisCount, (columnIndex) {
        return Expanded(
          child: Column(
            children: _columnItems[columnIndex].map((itemIndex) {
              return Container(
                margin: EdgeInsets.only(
                  right: columnIndex < widget.crossAxisCount - 1 ? widget.crossAxisSpacing : 0,
                  bottom: widget.mainAxisSpacing,
                ),
                child: widget.children[itemIndex],
              );
            }).toList(),
          ),
        );
      }),
    );
  }

  Widget _buildMeasureWidget() {
    return Opacity(
      opacity: 0,
      child: Column(
        children: widget.children.asMap().entries.map((entry) {
          return SizedBox(
            key: _keys.length > entry.key ? _keys[entry.key] : null,
            width: widget.itemWidth,
            child: entry.value,
          );
        }).toList(),
      ),
    );
  }

  @override
  void didUpdateWidget(_StaggeredGridViewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.children.length != oldWidget.children.length) {
      _generateKeys();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _measureAndArrange();
      });
    }
  }
}