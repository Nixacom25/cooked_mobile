import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/recipe.dart';

class SavedRecipeCard extends StatelessWidget {
  final Recipe? recipe;
  final String? title;
  final String? time;
  final String? kcal;
  final String? image;
  final bool isPinned;
  final VoidCallback? onPinTap;
  final VoidCallback? onTap;

  const SavedRecipeCard({
    super.key,
    this.recipe,
    this.title,
    this.time,
    this.kcal,
    this.image,
    this.isPinned = false,
    this.onPinTap,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String displayName = title ?? recipe?.name ?? 'Recipe';

    final int timeVal = (recipe?.prepTime != null && recipe!.prepTime! > 0)
        ? recipe!.prepTime!
        : ((recipe?.cookTime ?? 0) > 0 ? recipe!.cookTime : 10);
    final String prepTimeStr = time ?? '$timeVal min';

    final int kcalVal = (recipe?.kcal ?? 0) > 0 ? recipe!.kcal : 217;
    final String caloriesStr = kcal ?? '$kcalVal kcal';

    final String? imgPath = image ?? recipe?.image;
    final bool pinned = recipe?.isPinned ?? isPinned;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 125.h,
        decoration: BoxDecoration(
          color: const Color(0xFFFAF3E6),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: onPinTap,
                      child: Container(
                        width: 32.r,
                        height: 32.r,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            pinned ? Icons.favorite : Icons.favorite_border_rounded,
                            color: const Color(0xFFC31E26),
                            size: 16.sp,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        fontWeight: FontWeight.w700,
                        fontSize: 16.sp,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          _buildBadge(Icons.access_time_rounded, prepTimeStr),
                          SizedBox(width: 4.w),
                          _buildBadge(
                              Icons.local_fire_department_outlined, caloriesStr),
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
                      borderRadius: BorderRadius.circular(20.r),
                      child: _buildThumbnail(imgPath),
                    ),
                  ),
                  Positioned(
                    top: 10.h,
                    right: 10.w,
                    child: Container(
                      width: 32.r,
                      height: 32.r,
                      decoration: const BoxDecoration(
                        color: Colors.white,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF1E8DC),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: const Color(0xFF475569)),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Rubik',
              fontSize: 11.sp,
              color: const Color(0xFF334155),
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
