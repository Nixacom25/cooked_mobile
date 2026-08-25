import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/recipe.dart';

class RecipeHorizontalCard extends StatelessWidget {
  final Recipe? recipe;
  final String? title;
  final String? subtitle;
  final String? time;
  final String? kcal;
  final String? savingsText;
  final String? image;
  final bool isFavorite;
  final bool showChevron;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onTap;

  const RecipeHorizontalCard({
    super.key,
    this.recipe,
    this.title,
    this.subtitle,
    this.time,
    this.kcal,
    this.savingsText,
    this.image,
    this.isFavorite = false,
    this.showChevron = true,
    this.onFavoriteTap,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayTitle = title ?? recipe?.name ?? 'Recipe';
    final displaySubtitle = subtitle ??
        (recipe?.origin?.toUpperCase() == 'SCAN'
            ? "Scanned at home"
            : recipe != null
                ? "Saved in your cookbook"
                : null);

    final displayTime = time ?? (recipe?.cookTime != null ? '${recipe!.cookTime} min' : null);
    final displayKcal = kcal ?? (recipe?.kcal != null ? '${recipe!.kcal} kcal' : null);
    final displayImage = image ?? recipe?.image;

    final isNetwork = displayImage != null &&
        displayImage.isNotEmpty &&
        (displayImage.startsWith('http://') || displayImage.startsWith('https://'));
    final isAsset = displayImage != null && displayImage.startsWith('assets/');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        height: 140.h,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFFFAF6EE),
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Row(
          children: [
            // Left Info Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 14.h, 12.w, 14.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Row (Favorite Heart / Subtitle)
                    if (onFavoriteTap != null || isFavorite)
                      GestureDetector(
                        onTap: onFavoriteTap,
                        child: Container(
                          width: 34.r,
                          height: 34.r,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 18.sp,
                            color: const Color(0xFFC31E26),
                          ),
                        ),
                      )
                    else if (displaySubtitle != null)
                      Text(
                        displaySubtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Rubik',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),

                    // Recipe Title
                    Text(
                      displayTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                        height: 1.2,
                      ),
                    ),

                    // Bottom Row Badges (Time/Calorie OR Savings Badge)
                    if (savingsText != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 5.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          savingsText!,
                          style: TextStyle(
                            fontFamily: 'Rubik',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF16A34A),
                          ),
                        ),
                      )
                    else
                      Row(
                        children: [
                          if (displayTime != null)
                            _buildPillBadge(
                              icon: Icons.access_time_rounded,
                              text: displayTime,
                            ),
                          if (displayTime != null && displayKcal != null)
                            SizedBox(width: 8.w),
                          if (displayKcal != null)
                            _buildPillBadge(
                              icon: Icons.local_fire_department_rounded,
                              text: displayKcal,
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            // Right Image Container with Overlaid Action Chevron
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(24.r),
                    bottomRight: Radius.circular(24.r),
                  ),
                  child: SizedBox(
                    width: 155.w,
                    height: double.infinity,
                    child: isNetwork
                        ? CachedNetworkImage(
                            imageUrl: displayImage,
                            fit: BoxFit.cover,
                            placeholder: (_, __) =>
                                Container(color: Colors.grey[200]),
                            errorWidget: (_, __, ___) => Image.asset(
                              'assets/images/plat4.png',
                              fit: BoxFit.cover,
                            ),
                          )
                        : isAsset
                            ? Image.asset(
                                displayImage,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: const Color(0xFFF1F5F9),
                                  child: Icon(Icons.restaurant,
                                      color: Colors.grey[400]),
                                ),
                              )
                            : Image.asset(
                                'assets/images/plat4.png',
                                fit: BoxFit.cover,
                              ),
                  ),
                ),
                if (showChevron)
                  Positioned(
                    top: 12.h,
                    right: 12.w,
                    child: Container(
                      width: 32.r,
                      height: 32.r,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 20.sp,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillBadge({required IconData icon, required String text}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.sp, color: const Color(0xFF64748B)),
          SizedBox(width: 4.w),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Rubik',
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }
}
