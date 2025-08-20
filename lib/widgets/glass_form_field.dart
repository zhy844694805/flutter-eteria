import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/glassmorphism_theme.dart';
import '../widgets/glass_icons.dart';

/// 玻璃拟态无边框输入框
class GlassFormField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final String? initialValue;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final int maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final VoidCallback? onTap;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final String? Function(String?)? validator;
  final bool enabled;
  final bool readOnly;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final EdgeInsetsGeometry? contentPadding;

  const GlassFormField({
    super.key,
    this.label,
    this.hintText,
    this.initialValue,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.enabled = true,
    this.readOnly = false,
    this.focusNode,
    this.textInputAction = TextInputAction.done,
    this.inputFormatters,
    this.contentPadding,
  });

  @override
  State<GlassFormField> createState() => _GlassFormFieldState();
}

class _GlassFormFieldState extends State<GlassFormField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _focusAnimation;
  late Animation<Color?> _borderColorAnimation;
  
  bool _isFocused = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _focusAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _borderColorAnimation = ColorTween(
      begin: GlassmorphismColors.glassBorder,
      end: GlassmorphismColors.primary,
    ).animate(_focusAnimation);
    
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    
    if (_isFocused) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.label != null) ...[
              _buildLabel(),
              const SizedBox(height: 8),
            ],
            _buildInputField(),
          ],
        );
      },
    );
  }

  Widget _buildLabel() {
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 200),
      style: Theme.of(context).textTheme.labelMedium!.copyWith(
        color: _isFocused 
            ? GlassmorphismColors.primary 
            : GlassmorphismColors.textSecondary,
        fontWeight: FontWeight.w500,
      ),
      child: Text(widget.label!),
    );
  }

  Widget _buildInputField() {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              GlassmorphismColors.glassSurface.withValues(alpha: 0.8),
              GlassmorphismColors.glassSurface.withValues(alpha: 0.4),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _borderColorAnimation.value!,
            width: _isFocused ? 2.0 : 1.0,
          ),
          boxShadow: [
            if (_isFocused)
              BoxShadow(
                color: GlassmorphismColors.primary.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: IgnorePointer(
          ignoring: widget.readOnly, // 当只读时完全忽略TextFormField的交互
          child: TextFormField(
            controller: widget.controller,
            initialValue: widget.initialValue,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            textInputAction: widget.textInputAction,
            inputFormatters: widget.inputFormatters,
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onSubmitted,
            validator: widget.validator,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: GlassmorphismColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: GlassmorphismColors.textTertiary,
          ),
          prefixIcon: widget.prefixIcon != null
              ? Container(
                  margin: const EdgeInsets.only(left: 4),
                  child: widget.prefixIcon,
                )
              : null,
          suffixIcon: widget.suffixIcon != null
              ? GestureDetector(
                  onTap: widget.onSuffixIconTap,
                  child: Container(
                    margin: const EdgeInsets.only(right: 4),
                    child: widget.suffixIcon,
                  ),
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          contentPadding: widget.contentPadding ?? 
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          counterText: '', // 隐藏字符计数
        ),
      ),
    ),
    ));
  }
}

/// 玻璃拟态密码输入框
class GlassPasswordField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final bool enabled;
  final FocusNode? focusNode;

  const GlassPasswordField({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.focusNode,
  });

  @override
  State<GlassPasswordField> createState() => _GlassPasswordFieldState();
}

class _GlassPasswordFieldState extends State<GlassPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return GlassFormField(
      label: widget.label,
      hintText: widget.hintText,
      controller: widget.controller,
      obscureText: _obscureText,
      onChanged: widget.onChanged,
      validator: widget.validator,
      enabled: widget.enabled,
      focusNode: widget.focusNode,
      prefixIcon: Icon(
        GlassIcons.settings,
        color: GlassmorphismColors.textSecondary,
        size: 20,
      ),
      suffixIcon: Icon(
        _obscureText ? Icons.visibility : Icons.visibility_off,
        color: GlassmorphismColors.textSecondary,
        size: 20,
      ),
      onSuffixIconTap: () {
        setState(() {
          _obscureText = !_obscureText;
        });
      },
    );
  }
}

/// 玻璃拟态搜索框
class GlassSearchField extends StatefulWidget {
  final String? hintText;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final VoidCallback? onClear;
  final bool enabled;

  const GlassSearchField({
    super.key,
    this.hintText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.enabled = true,
  });

  @override
  State<GlassSearchField> createState() => _GlassSearchFieldState();
}

class _GlassSearchFieldState extends State<GlassSearchField> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
    _hasText = _controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasText = _controller.text.isNotEmpty;
    });
  }

  void _onClear() {
    _controller.clear();
    widget.onClear?.call();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return GlassFormField(
      hintText: widget.hintText ?? '搜索纪念...',
      controller: _controller,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      enabled: widget.enabled,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
      prefixIcon: Icon(
        GlassIcons.search,
        color: GlassmorphismColors.textSecondary,
        size: 20,
      ),
      suffixIcon: _hasText
          ? Icon(
              Icons.close,
              color: GlassmorphismColors.textSecondary,
              size: 20,
            )
          : null,
      onSuffixIconTap: _hasText ? _onClear : null,
    );
  }
}

/// 玻璃拟态日期选择器
class GlassDateField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final DateTime? selectedDate;
  final Function(DateTime?)? onDateSelected;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateTime? initialDate; // 添加初始日期参数
  final bool enabled;

  const GlassDateField({
    super.key,
    this.label,
    this.hintText,
    this.selectedDate,
    this.onDateSelected,
    this.firstDate,
    this.lastDate,
    this.initialDate,
    this.enabled = true,
  });

  @override
  State<GlassDateField> createState() => _GlassDateFieldState();
}

class _GlassDateFieldState extends State<GlassDateField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _updateControllerText();
  }

  @override
  void didUpdateWidget(GlassDateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      _updateControllerText();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateControllerText() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (widget.selectedDate != null) {
          _controller.text = 
              '${widget.selectedDate!.year}-${widget.selectedDate!.month.toString().padLeft(2, '0')}-${widget.selectedDate!.day.toString().padLeft(2, '0')}';
        } else {
          _controller.text = '';
        }
      }
    });
  }

  Future<void> _selectDate() async {
    print('🗓️ [GlassDateField] _selectDate called');
    if (!widget.enabled) {
      print('🗓️ [GlassDateField] Widget is disabled, returning');
      return;
    }
    
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: widget.selectedDate ?? widget.initialDate ?? DateTime.now(),
        firstDate: widget.firstDate ?? DateTime(1900),
        lastDate: widget.lastDate ?? DateTime.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: GlassmorphismColors.primary,
                onPrimary: Colors.white,
                surface: GlassmorphismColors.backgroundPrimary,
                onSurface: GlassmorphismColors.textPrimary,
              ),
            ),
            child: child!,
          );
        },
      );

      print('🗓️ [GlassDateField] Date picked: $picked');
      if (picked != null) {
        widget.onDateSelected?.call(picked);
      }
    } catch (e) {
      print('❌ [GlassDateField] Error selecting date: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassFormField(
      label: widget.label,
      hintText: widget.hintText ?? '选择日期',
      controller: _controller,
      enabled: widget.enabled,
      readOnly: true,
      prefixIcon: Icon(
        Icons.calendar_today,
        color: GlassmorphismColors.textSecondary,
        size: 20,
      ),
      suffixIcon: Icon(
        Icons.arrow_drop_down,
        color: GlassmorphismColors.textSecondary,
        size: 20,
      ),
      onSuffixIconTap: widget.enabled ? _selectDate : null,
      onTap: widget.enabled ? _selectDate : null,
    );
  }
}

/// 玻璃拟态下拉选择框
class GlassDropdownField<T> extends StatefulWidget {
  final String? label;
  final String? hintText;
  final T? value;
  final List<T> items;
  final String Function(T) itemBuilder;
  final Function(T?)? onChanged;
  final bool enabled;

  const GlassDropdownField({
    super.key,
    this.label,
    this.hintText,
    this.value,
    required this.items,
    required this.itemBuilder,
    this.onChanged,
    this.enabled = true,
  });

  @override
  State<GlassDropdownField<T>> createState() => _GlassDropdownFieldState<T>();
}

class _GlassDropdownFieldState<T> extends State<GlassDropdownField<T>> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _updateControllerText();
  }

  @override
  void didUpdateWidget(GlassDropdownField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _updateControllerText();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateControllerText() {
    final value = widget.value;
    if (value != null) {
      _controller.text = widget.itemBuilder(value);
    } else {
      _controller.text = '';
    }
  }

  Future<void> _showOptions() async {
    final T? selected = await showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) => Container(
        decoration: BoxDecoration(
          gradient: GlassmorphismColors.backgroundGradient,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 顶部指示器
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: GlassmorphismColors.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // 标题
            if (widget.label != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    Text(
                      widget.label!,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: GlassmorphismColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('完成'),
                    ),
                  ],
                ),
              ),
            const Divider(height: 1),
            // 选项列表
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  final isSelected = item == widget.value;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    title: Text(
                      widget.itemBuilder(item),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isSelected 
                            ? GlassmorphismColors.primary 
                            : GlassmorphismColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                      ),
                    ),
                    trailing: isSelected 
                        ? Icon(
                            Icons.check,
                            color: GlassmorphismColors.primary,
                            size: 20,
                          )
                        : null,
                    onTap: () => Navigator.pop(context, item),
                  );
                },
              ),
            ),
            // 底部安全区域
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );

    // 在bottom sheet关闭后更新状态
    if (selected != null && selected != widget.value) {
      _controller.text = widget.itemBuilder(selected);
      widget.onChanged?.call(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassFormField(
      label: widget.label,
      hintText: widget.hintText ?? '请选择',
      controller: _controller,
      enabled: widget.enabled,
      readOnly: true,
      suffixIcon: Icon(
        Icons.arrow_drop_down,
        color: GlassmorphismColors.textSecondary,
        size: 20,
      ),
      onSuffixIconTap: widget.enabled ? _showOptions : null,
      onTap: widget.enabled ? _showOptions : null,
    );
  }
}