import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/theme/app_theme.dart';
import '../core/motion/motion_widgets.dart';

class AppSearchField extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Color? backgroundColor;
  final Color? borderColor;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final double? borderRadius;
  final FocusNode? focusNode;

  const AppSearchField({
    super.key,
    this.controller,
    this.hintText = 'Search your recipes',
    this.onChanged,
    this.onSubmitted,
    this.backgroundColor,
    this.borderColor,
    this.suffixIcon,
    this.onSuffixTap,
    this.borderRadius,
    this.focusNode,
  });

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  FocusNode? _ownFocus;
  FocusNode get _focus => widget.focusNode ?? (_ownFocus ??= FocusNode());
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocus);
  }

  void _onFocus() {
    if (mounted && _focus.hasFocus != _focused) {
      setState(() => _focused = _focus.hasFocus);
    }
  }

  @override
  void didUpdateWidget(AppSearchField old) {
    super.didUpdateWidget(old);
    if (old.focusNode != widget.focusNode) {
      (old.focusNode ?? _ownFocus)?.removeListener(_onFocus);
      _focus.addListener(_onFocus);
    }
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocus);
    _ownFocus?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final d = Motion.of(context, Motion.micro);
    // Focus: border gets more pronounced, icon shifts slightly left and
    // turns accent, the suffix control fades in (~180 ms).
    return AnimatedContainer(
      duration: d,
      curve: Motion.standard,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? colors.surface,
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 50.r),
        border: Border.all(
          color: _focused ? colors.accent.withValues(alpha: 0.6) : (widget.borderColor ?? colors.border),
          width: _focused ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.accent.withValues(alpha: _focused ? 0.10 : 0),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Row(
        children: [
          AnimatedSlide(
            duration: d,
            curve: Motion.standard,
            offset: Offset(_focused ? -0.08 : 0, 0),
            child: TweenAnimationBuilder<Color?>(
              tween: ColorTween(end: _focused ? colors.accent : colors.textMuted),
              duration: d,
              builder: (context, c, _) => Icon(Icons.search_rounded, size: 30.sp, color: c),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focus,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              textCapitalization: TextCapitalization.words,
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 14.sp,
                color: colors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  fontFamily: 'SF Pro',
                  fontSize: 14.sp,
                  color: colors.textMuted,
                ),
                filled: true,
                fillColor:
                    Colors.transparent, // background is handled by Container
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: d,
            transitionBuilder: (child, a) => FadeTransition(
              opacity: a,
              child: ScaleTransition(scale: Tween(begin: 0.8, end: 1.0).animate(a), child: child),
            ),
            child: widget.suffixIcon != null
                ? GestureDetector(
                    key: ValueKey(widget.suffixIcon),
                    onTap: widget.onSuffixTap,
                    child: Padding(
                      padding: EdgeInsets.only(left: 8.w),
                      child: Icon(widget.suffixIcon, size: 22.sp, color: colors.accent),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
