import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/recipe.dart';

class SavedRecipeCard extends StatelessWidget {
  final Recipe? recipe;
  final String? title;
  final String? subtitle;
  final String? time;
  final String? kcal;
  final String? image;
  final bool isPinned;
  final bool isSavingsMode;
  final String? savingsBadgeText;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onPinTap;
  final VoidCallback? onTap;
  final Function(LongPressStartDetails)? onLongPressStart;
  final VoidCallback? onLongPress;

  const SavedRecipeCard({
    super.key,
    this.recipe,
    this.title,
    this.subtitle,
    this.time,
    this.kcal,
    this.image,
    this.isPinned = false,
    this.isSavingsMode = false,
    this.savingsBadgeText,
    this.onFavoriteTap,
    this.onPinTap,
    this.onTap,
    this.onLongPressStart,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final String displayName = title ?? recipe?.name ?? 'Recipe';
    final String? imgPath = image ?? recipe?.image;

    if (isSavingsMode) {
      return GestureDetector(
        onTap: onTap,
        onLongPressStart: onLongPressStart,
        onLongPress: onLongPress,
        child: Container(
          height: 135.h,
          decoration: BoxDecoration(
            color: const Color(0xFFFAF3E6),
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontWeight: FontWeight.w700,
                              fontSize: 16.sp,
                              color: const Color(0xFF0F172A),
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            subtitle ?? 'Scanned at home',
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontWeight: FontWeight.w400,
                              fontSize: 13.sp,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          savingsBadgeText ?? '+14\$',
                          style: TextStyle(
                            fontFamily: 'Rubik',
                            fontWeight: FontWeight.w700,
                            fontSize: 12.sp,
                            color: const Color(0xFF15803D),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24.r),
                  child: SizedBox(
                    height: double.infinity,
                    child: _buildThumbnail(imgPath),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final int timeVal = (recipe?.prepTime != null && recipe!.prepTime! > 0)
        ? recipe!.prepTime!
        : ((recipe?.cookTime ?? 0) > 0 ? recipe!.cookTime : 10);
    final String prepTimeStr = time ?? '$timeVal min';

    final int kcalVal = (recipe?.kcal ?? 0) > 0 ? recipe!.kcal : 217;
    final String caloriesStr = kcal ?? '$kcalVal kcal';
    final bool pinned = recipe?.isPinned ?? isPinned;

    return GestureDetector(
      onTap: onTap,
      onLongPressStart: onLongPressStart,
      onLongPress: onLongPress,
      child: Container(
        height: 135.h,
        decoration: BoxDecoration(
          color: const Color(0xFFFAF3E6),
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: onFavoriteTap ?? onPinTap,
                      child: Container(
                        width: 32.r,
                        height: 32.r,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            (recipe?.isFavorite ?? false)
                                ? 'assets/icones/coeur.svg'
                                : 'assets/icones/coeur1.svg',
                            width: 16.r,
                            height: 16.r,
                            colorFilter: ColorFilter.mode(
                              (recipe?.isFavorite ?? false)
                                  ? const Color(0xFFC83A2D)
                                  : const Color(0xFF94A3B8),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        fontWeight: FontWeight.w700,
                        fontSize: 16.sp,
                        color: const Color(0xFF0F172A),
                        height: 1.2,
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          _buildBadge(Icons.access_time_rounded, prepTimeStr),
                          SizedBox(width: 6.w),
                          _buildBadge(
                            Icons.local_fire_department_outlined,
                            caloriesStr,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24.r),
                      child: _buildThumbnail(imgPath),
                    ),
                  ),
                  if (pinned)
                    Positioned(
                      bottom: 10.h,
                      right: 10.w,
                      child: GestureDetector(
                        onTap: onPinTap,
                        child: Icon(
                          Icons.push_pin_rounded,
                          size: 20.sp,
                          color: Colors.white,
                          shadows: const [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EAD9),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: const Color(0xFF64748B)),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Rubik',
              fontSize: 11.sp,
              color: const Color(0xFF475569),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(String? image) {
    const fallback = 'assets/images/recipes.png';
    if (image == null || image.isEmpty || image == 'null') {
      return Image.asset(fallback, fit: BoxFit.cover);
    }
    if (image.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: image,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(color: const Color(0xFFEEEEEE)),
        errorWidget: (_, __, ___) => Image.asset(fallback, fit: BoxFit.cover),
      );
    }
    return Image.asset(
      image,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Image.asset(fallback, fit: BoxFit.cover),
    );
  }
}
