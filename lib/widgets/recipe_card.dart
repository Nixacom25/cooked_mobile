import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/recipe.dart';

import 'skeleton_loader.dart';

class RecipeCard extends StatelessWidget {
  final Recipe? recipe;
  // Fallback fields for backward compatibility during migration
  final String? img;
  final String? name;
  final String? time;
  final String? kcal;
  final bool hearted;
  final bool useValidationIcon;
  final bool isValidated;
  final VoidCallback? onHeartTap;
  final VoidCallback? onSaveTap;
  final VoidCallback? onValidateTap;
  final VoidCallback? onTap;

  const RecipeCard({
    super.key,
    this.recipe,
    this.img,
    this.name,
    this.time,
    this.kcal,
    this.hearted = false,
    this.useValidationIcon = false,
    this.isValidated = false,
    this.onHeartTap,
    this.onSaveTap,
    this.onValidateTap,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayImg = recipe?.image ?? img ?? '';
    final displayName = recipe?.name ?? name ?? 'Unknown Recipe';
    final displayTime = recipe != null
        ? '${recipe!.cookTime} min'
        : (time ?? '');
    final displayKcal = recipe != null ? '${recipe!.kcal} kcal' : (kcal ?? '');
    final isHearted = recipe?.isFavorite ?? hearted;

    return GestureDetector(
      onTap: onTap,
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
                // Heart icon top-right
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: GestureDetector(
                    onTap: useValidationIcon ? onValidateTap : onHeartTap,
                    child: Container(
                      padding: EdgeInsets.all(6.r),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        useValidationIcon
                            ? (isValidated
                                ? Icons.check_circle_rounded
                                : Icons.add_circle_outline_rounded)
                            : (isHearted
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded),
                        color: useValidationIcon
                            ? (isValidated
                                ? Colors.green
                                : const Color(0xFFAAAAAA))
                            : (isHearted
                                ? const Color(0xFFC83A2D)
                                : const Color(0xFFAAAAAA)),
                        size: useValidationIcon ? 20.sp : 18.sp,
                      ),
                    ),
                  ),
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
                          color: const Color(0xFFC83A2D),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4.r,
                              offset: Offset(0, 2.h),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.bookmark_add_rounded,
                          color: Colors.white,
                          size: 18.sp,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          SizedBox(height: 8.h),

          // ── Info area ──────────────────────────────────────────────────
          Text(
            displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w700,
              fontSize: 14.sp,
              color: const Color(0xFF222222),
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Icon(
                Icons.timer,
                size: 12.sp,
                color: const Color(0xFF9CA3AF),
              ),
              SizedBox(width: 3.w),
              Text(
                displayTime,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontSize: 11.sp,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.local_fire_department,
                size: 12.sp,
                color: const Color(0xFF9CA3AF),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  displayKcal,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontSize: 11.sp,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildImage(String path) {
    if (path.isEmpty) {
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
