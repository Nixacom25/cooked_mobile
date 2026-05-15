import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/cookbook.dart';
import '../models/recipe.dart';
import 'skeleton_loader.dart';

class CookbookCover extends StatelessWidget {
  final Cookbook cookbook;
  final double? width;
  final double? height;

  const CookbookCover({
    super.key,
    required this.cookbook,
    this.width,
    this.height,
  });


  @override
  Widget build(BuildContext context) {
    final recipes = List<Recipe>.from(cookbook.recipes);
    
    // Sort logic: 
    // 1. Prioritize recipes WITH images first
    // 2. Among those, prioritize 'IMPORT' origin
    // 3. Among those, prioritize recipes with sourceUrl
    // 4. Finally, sort by createdAt descending
    recipes.sort((a, b) {
      final aHasImage = a.image != null && a.image!.isNotEmpty;
      final bHasImage = b.image != null && b.image!.isNotEmpty;
      
      // If one has an image and the other doesn't, image wins
      if (aHasImage && !bHasImage) return -1;
      if (!aHasImage && bHasImage) return 1;
      
      // If both have images (or both don't), prioritize IMPORT origin
      final aIsImport = a.origin?.toUpperCase() == 'IMPORT';
      final bIsImport = b.origin?.toUpperCase() == 'IMPORT';
      
      if (aIsImport && !bIsImport) return -1;
      if (!aIsImport && bIsImport) return 1;

      // Then prioritize those with source URLs
      final aHasUrl = a.sourceUrl != null && a.sourceUrl!.isNotEmpty;
      final bHasUrl = b.sourceUrl != null && b.sourceUrl!.isNotEmpty;
      
      if (aHasUrl && !bHasUrl) return -1;
      if (!aHasUrl && bHasUrl) return 1;
      
      // Finally by date
      return b.createdAt.compareTo(a.createdAt);
    });
    
    final displayRecipes = recipes.take(3).toList();
    final bool isPinned = cookbook.isPinned;

    return Stack(
      children: [
        Container(
          width: width ?? double.infinity,
          height: height ?? double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(16.r),
          ),
          clipBehavior: Clip.antiAlias,
          child: displayRecipes.isEmpty 
              ? _buildEmptyState() 
              : _buildCollage(displayRecipes),
        ),
        if (isPinned)
          Positioned(
            bottom: 4.h,
            right: 4.w,
            child: Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.push_pin_rounded,
                size: 12.sp,
                color: const Color(0xFFC83A2D),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    String assetPath = 'assets/images/cookbook.png';

    return Image.asset(
      assetPath,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF9FAFB),
            const Color(0xFFF3F4F6),
          ],
        ),
      ),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: const Color(0xFFC83A2D).withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: Image.asset(
            'assets/images/cookbook.png',
            width: 45.w,
            height: 45.h,
            fit: BoxFit.cover,
            color: const Color(0xFFC83A2D).withOpacity(0.3),
            colorBlendMode: BlendMode.srcIn,
          ),
        ),
      ),
    );
  }

  Widget _buildCollage(List<Recipe> recipes) {
    if (recipes.length == 1) {
      return _buildImage(recipes[0].image);
    } else if (recipes.length == 2) {
      return Row(
        children: [
          Expanded(
            child: _buildImage(recipes[0].image),
          ),
          Container(width: 1.5, color: Colors.white),
          Expanded(
            child: _buildImage(recipes[1].image),
          ),
        ],
      );
    } else {
      // 3 recipes (latest)
      final String? img1 = recipes[0].image;
      final String? img2 = recipes[1].image;
      final String? img3 = recipes[2].image;

      return Row(
        children: [
          // Left - Large image
          Expanded(
            flex: 3,
            child: _buildImage(img1),
          ),
          Container(width: 1.5, color: Colors.white),
          // Right - Two small images stacked
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Expanded(
                  child: _buildImage(img2),
                ),
                Container(height: 1.5, color: Colors.white),
                Expanded(
                  child: _buildImage(img3),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }

  Widget _buildImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Image.asset(
        'assets/images/recipes.png',
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorWidget: (_, __, ___) => Image.asset(
        'assets/images/recipes.png',
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      ),
      placeholder: (_, __) => const SkeletonLoader(
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }

}
