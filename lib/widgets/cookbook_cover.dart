import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/cookbook.dart';
import '../models/recipe.dart';

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
    final recipes = cookbook.recipes;
    final recipesWithImages = recipes.where((r) => r.image != null && r.image!.isNotEmpty).toList();

    return Container(
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: recipesWithImages.isEmpty 
          ? _buildEmptyState() 
          : _buildCollage(recipesWithImages),
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
            color: const Color(0xFFCC3333).withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
          child: Image.asset(
            'assets/images/cookbook.png',
            width: 45.w,
            height: 45.h,
            fit: BoxFit.contain,
            color: const Color(0xFFCC3333).withValues(alpha: 0.3),
            colorBlendMode: BlendMode.srcIn,
          ),
        ),
      ),
    );
  }

  Widget _buildCollage(List<Recipe> recipes) {
    // Always use 3 slots (1 large left, 2 small right)
    // Repeat images if we have less than 3
    final String? img1 = recipes.isNotEmpty ? recipes[0].image : null;
    final String? img2 = recipes.length > 1 ? recipes[1].image : null;
    final String? img3 = recipes.length > 2 ? recipes[2].image : null;

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

  Widget _buildImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        color: const Color(0xFFF2EFED),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      errorWidget: (_, __, ___) =>
          Image.asset('assets/images/recipes.png', fit: BoxFit.contain),
      placeholder: (_, __) => Container(
        color: const Color(0xFFE5E7EB),
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFFCC3333),
          ),
        ),
      ),
    );
  }

}
