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

    return Container(
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: Colors.white),
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildCoverContent(recipes),
    );
  }

  Widget _buildCoverContent(List<Recipe> recipes) {
    // Prioritize recipes that actually have images for the collage
    final recipesWithImages = recipes.where((r) => r.image != null && r.image!.isNotEmpty).toList();
    final int count = recipesWithImages.length;
    
    if (count == 0) {
      // Premium placeholder for empty cookbook
      return Container(
        color: const Color(0xFFF9FAFB),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/cookbook.png',
                width: 60.w,
                height: 60.h,
                fit: BoxFit.contain,
                color: const Color(0xFFCC3333).withValues(alpha: 0.1),
                colorBlendMode: BlendMode.srcIn,
              ),
            ],
          ),
        ),
      );
    }
    
    return Row(
      children: [
        // Left - Large image
        Expanded(
          flex: 3,
          child: _buildImage(count > 0 ? recipesWithImages[0].image : null),
        ),
        Container(width: 1, color: Colors.white),
        // Right - Two small images stacked
        Expanded(
          flex: 2,
          child: Column(
            children: [
              Expanded(
                child: _buildImage(count > 1 ? recipesWithImages[1].image : null),
              ),
              Container(height: 1, color: Colors.white),
              Expanded(
                child: _buildImage(count > 2 ? recipesWithImages[2].image : null),
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
        color: const Color(0xFFF3F3F3),
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
