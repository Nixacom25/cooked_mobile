import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/cookbook.dart';
import '../routes/app_routes.dart';
import '../services/cookbook_service.dart';
import '../core/widgets/ios_toast.dart';
import 'cookbook_cover.dart';
import 'cookbook_form_modal.dart';
import 'haptic_context_menu.dart';

/// Cookbook tile shared by Home's "Your Cookbooks" row and the Cookbooks
/// "View All" grid so both look exactly the same. [isMain] renders the
/// larger tile (cover image + name below); the small variant stacks
/// overlapping recipe thumbnails above the name/count row.
class CookbookCardTile extends StatelessWidget {
  final Cookbook cookbook;
  final bool isMain;
  final VoidCallback? onRefresh;

  const CookbookCardTile({
    super.key,
    required this.cookbook,
    required this.isMain,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.pushNamed(
          context,
          AppRoutes.cookbookDetail,
          arguments: {'cookbook': cookbook},
        );
        if (result == true) {
          CookbookService.instance.getMyCookbooks();
          onRefresh?.call();
        }
      },
      onLongPressStart: (details) {
        HapticContextMenu.show(
          context,
          targetPosition: details.globalPosition,
          actions: [
            HapticMenuAction(
              title: cookbook.isPinned ? 'Unpin Cookbook' : 'Pin Cookbook',
              icon: cookbook.isPinned
                  ? Icons.push_pin_rounded
                  : Icons.push_pin_outlined,
              onTap: () async {
                try {
                  await CookbookService.instance.togglePin(cookbook.id);
                  onRefresh?.call();
                } catch (_) {}
              },
            ),
            HapticMenuAction(
              title: 'Edit Cookbook',
              icon: Icons.edit_outlined,
              onTap: () async {
                final result = await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => CookbookFormModal(cookbook: cookbook),
                );
                if (result is Cookbook || result == 'deleted') {
                  CookbookService.instance.getMyCookbooks(forceRefresh: true);
                  onRefresh?.call();
                }
              },
            ),
            HapticMenuAction(
              title: 'Delete Cookbook',
              icon: Icons.delete_outline_rounded,
              isDestructive: true,
              onTap: () async {
                try {
                  await CookbookService.instance.deleteCookbook(cookbook.id);
                  if (context.mounted) {
                    IosToast.show(
                      context,
                      message: 'Cookbook deleted',
                      type: ToastType.success,
                    );
                  }
                  onRefresh?.call();
                } catch (e) {
                  if (context.mounted) {
                    IosToast.show(
                      context,
                      message: 'Failed to delete cookbook',
                      type: ToastType.error,
                    );
                  }
                }
              },
            ),
          ],
        );
      },
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF3E6),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: isMain
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.r),
                          child: CookbookCover(cookbook: cookbook),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        cookbook.name.isEmpty
                            ? cookbook.name
                            : cookbook.name[0].toUpperCase() +
                                  cookbook.name.substring(1).toLowerCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Rubik',
                          fontWeight: FontWeight.w700,
                          fontSize: 16.sp,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.restaurant_menu_rounded,
                            size: 14.sp,
                            color: const Color(0xFF475569),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '${cookbook.recipes.length} Recipes',
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontSize: 13.sp,
                              color: const Color(0xFF475569),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 18.sp,
                            color: const Color(0xFF475569),
                          ),
                        ],
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildOverlappingThumbnails(cookbook),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cookbook.name.isEmpty
                                ? cookbook.name
                                : cookbook.name[0].toUpperCase() +
                                      cookbook.name.substring(1).toLowerCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontWeight: FontWeight.w700,
                              fontSize: 14.sp,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Row(
                            children: [
                              Icon(
                                Icons.restaurant_menu_rounded,
                                size: 13.sp,
                                color: const Color(0xFF475569),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                '${cookbook.recipes.length} Recipes',
                                style: TextStyle(
                                  fontFamily: 'Rubik',
                                  fontSize: 12.sp,
                                  color: const Color(0xFF475569),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 16.sp,
                                color: const Color(0xFF475569),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
          if (cookbook.isPinned)
            Positioned(
              top: 10.h,
              right: 10.w,
              child: Icon(
                Icons.push_pin_rounded,
                size: 20.sp,
                color: const Color(0xFFC83A2D),
                shadows: const [Shadow(color: Colors.black26, blurRadius: 4)],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOverlappingThumbnails(Cookbook cb) {
    final List<String> images = cb.recipes
        .map((r) => r.image)
        .where((img) => img != null && img.isNotEmpty)
        .cast<String>()
        .toList();

    if (images.isEmpty) {
      return Container(
        width: 32.r,
        height: 32.r,
        decoration: const BoxDecoration(
          color: Color(0xFFE2E8F0),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.menu_book_rounded,
          size: 16.sp,
          color: const Color(0xFF475569),
        ),
      );
    }

    return SizedBox(
      height: 34.r,
      child: Stack(
        children: List.generate(images.take(3).length, (idx) {
          return Positioned(
            left: idx * 18.w,
            child: Container(
              width: 34.r,
              height: 34.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFAF3E6), width: 2),
              ),
              child: ClipOval(
                child: images[idx].startsWith('http')
                    ? CachedNetworkImage(
                        imageUrl: images[idx],
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Image.asset(
                          'assets/images/recipes.png',
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset(images[idx], fit: BoxFit.cover),
              ),
            ),
          );
        }),
      ),
    );
  }
}
