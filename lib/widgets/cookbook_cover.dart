import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/cookbook.dart';

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

  static const String _defaultPlaceholder = 'assets/images/cookbook.png';

  @override
  Widget build(BuildContext context) {
    final recipes = cookbook.recipes;

    return Container(
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildCoverContent(recipes),
    );
  }

  Widget _buildCoverContent(List recipes) {
    if (recipes.isEmpty) {
      return Image.asset(
        _defaultPlaceholder,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholderIcon(),
      );
    }

    final int count = recipes.length;
    final displayRecipes = count > 4 ? recipes.sublist(0, 4) : recipes;

    if (count == 1) {
      return _buildImage(displayRecipes[0].image);
    }

    if (count == 2) {
      return Row(
        children: [
          Expanded(child: _buildImage(displayRecipes[0].image)),
          const SizedBox(width: 1.5),
          Expanded(child: _buildImage(displayRecipes[1].image)),
        ],
      );
    }

    if (count == 3) {
      return Row(
        children: [
          Expanded(child: _buildImage(displayRecipes[0].image)),
          const SizedBox(width: 1.5),
          Expanded(
            child: Column(
              children: [
                Expanded(child: _buildImage(displayRecipes[1].image)),
                const SizedBox(height: 1.5),
                Expanded(child: _buildImage(displayRecipes[2].image)),
              ],
            ),
          ),
        ],
      );
    }

    // Grid for 4 or more
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildImage(displayRecipes[0].image)),
              const SizedBox(width: 1.5),
              Expanded(child: _buildImage(displayRecipes[1].image)),
            ],
          ),
        ),
        const SizedBox(height: 1.5),
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildImage(displayRecipes[2].image)),
              const SizedBox(width: 1.5),
              Expanded(child: _buildImage(displayRecipes[3].image)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Image.asset('assets/images/recipes.png', fit: BoxFit.cover);
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      errorWidget: (_, __, ___) =>
          Image.asset('assets/images/recipes.png', fit: BoxFit.cover),
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

  Widget _buildPlaceholderIcon() {
    return Center(
      child: Icon(
        Icons.restaurant_menu_rounded,
        size: 42.sp,
        color: const Color(0xFFCCCCCC),
      ),
    );
  }
}
