import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/extensions/string_extensions.dart';
import '../models/recipe.dart';
import 'skeleton_loader.dart';
import 'animated_validation_button.dart';
import 'standard_plus_button.dart';
import 'haptic_context_menu.dart';

class RecipeCard extends StatelessWidget {
  final Recipe? recipe;
  // Fallback fields for backward compatibility during migration
  final String? img;
  final String? name;
  final String? time;
  final String? kcal;
  final bool useValidationIcon;
  final bool isValidated;
  final VoidCallback? onSaveTap;
  final VoidCallback? onValidateTap;
  final VoidCallback? onTap;
  final Duration animationDelay;
  final int index;
  final bool disableSlide;
  final bool useExploreButton;
  final bool useScanButton;
  final Color? activeColor;
  final Color? inactiveColor;
  final VoidCallback? onEditTap;
  final VoidCallback? onShareTap;
  final VoidCallback? onPinTap;
  final VoidCallback? onDeleteTap;
  final VoidCallback? onAddToCookbookTap;
  final VoidCallback? onRemoveFromCookbookTap;
  final int? rank;

  const RecipeCard({
    super.key,
    this.rank,
    this.recipe,
    this.img,
    this.name,
    this.time,
    this.kcal,
    this.useValidationIcon = false,
    this.isValidated = false,
    this.onSaveTap,
    this.onValidateTap,
    this.onTap,
    this.animationDelay = Duration.zero,
    this.index = 0,
    this.disableSlide = true,
    this.useExploreButton = false,
    this.useScanButton = false,
    this.activeColor,
    this.inactiveColor,
    this.onEditTap,
    this.onShareTap,
    this.onPinTap,
    this.onDeleteTap,
    this.onAddToCookbookTap,
    this.onRemoveFromCookbookTap,
  });

  String get displayName => (recipe?.name ?? name ?? '').toTitleCase();
  String get displayTime => recipe != null ? '${recipe!.cookTime} min' : (time ?? '');
  String get displayKcal => recipe != null ? '${recipe!.kcal} kcal' : (kcal ?? '');

  @override
  Widget build(BuildContext context) {
    if (recipe?.isPlaceholder == true) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SkeletonLoader(
              width: double.infinity,
              height: double.infinity,
              borderRadius: 12.r,
            ),
          ),
          SizedBox(height: 8.h),
          const SkeletonLoader(width: 120, height: 14),
          SizedBox(height: 4.h),
          const SkeletonLoader(width: 80, height: 10),
        ],
      );
    }

    final displayImg = recipe?.image ?? img ?? '';

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      onLongPressStart: (onEditTap == null && onShareTap == null && onPinTap == null && onDeleteTap == null && onAddToCookbookTap == null && onRemoveFromCookbookTap == null)
          ? null
          : (details) {
              HapticFeedback.heavyImpact();
              _showContextMenu(context, details.globalPosition);
            },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Photo area ─────────────────────────────────────────────────
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(12.r)),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: const Color(0xFFF2F1EF),
                      child: _buildImage(displayImg),
                    ),
                  ),
                ),
                // Top-right icon (Validation)
                if (useValidationIcon)
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: _buildValidationButton(),
                  ),
                // Save icon bottom-right
                if (onSaveTap != null)
                  Positioned(
                    bottom: 8.h,
                    right: 8.w,
                    child: GestureDetector(
                      onTap: onSaveTap,
                      child: Container(
                        padding: EdgeInsets.all(6.r),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.bookmark_border_rounded,
                          color: const Color(0xFF1A1A1A),
                          size: 18.sp,
                        ),
                      ),
                    ),
                  ),
                if (recipe?.isPinned == true)
                  Positioned(
                    bottom: 4.h,
                    right: useValidationIcon ? 46.w : 4.w,
                    child: Container(
                      padding: EdgeInsets.all(5.r),
                      child: Icon(
                        Icons.push_pin_rounded,
                        size: 16.sp,
                        color: const Color(0xFFC83A2D),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (rank != null) ...[
                  Text(
                    '$rank',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.bold,
                      fontSize: 20.sp,
                      color: const Color(0xFFD1D1D6),
                    ),
                  ),
                  SizedBox(width: 8.w),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w700,
                          fontSize: 14.sp,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 12.sp,
                            color: const Color(0xFF8E8E93),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            displayTime,
                            style: TextStyle(
                              fontFamily: 'SF Pro',
                              fontSize: 11.sp,
                              color: const Color(0xFF8E8E93),
                            ),
                          ),
                          if (displayKcal.isNotEmpty) ...[
                            SizedBox(width: 8.w),
                            Icon(
                              Icons.local_fire_department_outlined,
                              size: 12.sp,
                              color: const Color(0xFF8E8E93),
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              displayKcal,
                              style: TextStyle(
                                fontFamily: 'SF Pro',
                                fontSize: 11.sp,
                                color: const Color(0xFF8E8E93),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showContextMenu(BuildContext context, Offset position) {
    HapticContextMenu.show(
      context,
      targetPosition: position,
      actions: [
        if (onAddToCookbookTap != null && (recipe == null || !recipe!.isInCookbook))
          HapticMenuAction(
            title: 'Add to Cookbook',
            icon: Icons.add_circle_outline_rounded,
            onTap: onAddToCookbookTap!,
          ),
        if (onRemoveFromCookbookTap != null)
          HapticMenuAction(
            title: 'Remove from Cookbook',
            icon: Icons.remove_circle_outline_rounded,
            isDestructive: true,
            onTap: onRemoveFromCookbookTap!,
          ),
        if (onPinTap != null)
          HapticMenuAction(
            title: (recipe?.isPinned == true) ? 'Unpin Recipe' : 'Pin Recipe',
            icon: (recipe?.isPinned == true) ? Icons.push_pin_rounded : Icons.push_pin_outlined,
            onTap: onPinTap!,
          ),
        if (onShareTap != null)
          HapticMenuAction(
            title: 'Share Recipe',
            icon: Icons.ios_share_rounded,
            onTap: onShareTap!,
          ),
        if (onDeleteTap != null)
          HapticMenuAction(
            title: 'Delete Recipe',
            icon: Icons.delete_outline_rounded,
            isDestructive: true,
            onTap: onDeleteTap!,
          ),
      ],
    );
  }

  Widget _buildValidationButton() {
    if (useExploreButton || useScanButton || disableSlide) {
      return StandardPlusButton(
        isValidated: isValidated,
        onTap: onValidateTap,
        inactiveColor: inactiveColor,
      );
    }

    return _StaggeredIcon(
      delay: animationDelay,
      child: AnimatedValidationButton(
        isValidated: isValidated,
        onTap: onValidateTap,
        autoAnimate: false,
        index: index,
        disableSlide: false,
        activeColor: activeColor,
        inactiveColor: inactiveColor,
      ),
    );
  }

  Widget _buildImage(String path) {
    if (path.isEmpty || path == 'null') {
      return Image.asset('assets/images/recipes.png', fit: BoxFit.cover);
    }

    if (path.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: path,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) =>
            Image.asset('assets/images/recipes.png', fit: BoxFit.cover),
        placeholder: (_, __) => const SkeletonLoader(
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }

    // Assume asset path
    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          Image.asset('assets/images/recipes.png', fit: BoxFit.cover),
    );
  }
}

class _StaggeredIcon extends StatefulWidget {
  final Widget child;
  final Duration delay;
  const _StaggeredIcon({required this.child, required this.delay});
  @override
  State<_StaggeredIcon> createState() => _StaggeredIconState();
}

class _StaggeredIconState extends State<_StaggeredIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _timer = Timer(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _scale, child: widget.child);
  }
}
