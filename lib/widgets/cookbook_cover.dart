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


  @override
  Widget build(BuildContext context) {
    final recipes = cookbook.recipes;

    return Container(
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildCoverContent(recipes),
    );
  }

  Widget _buildCoverContent(List recipes) {
    final int count = recipes.length;
    
    return Row(
      children: [
        // Left - Large image
        Expanded(
          flex: 3,
          child: _buildImage(count > 0 ? recipes[0].image : null),
        ),
        Container(width: 1.5, color: Colors.white),
        // Right - Two small images stacked
        Expanded(
          flex: 2,
          child: Column(
            children: [
              Expanded(
                child: _buildImage(count > 1 ? recipes[1].image : null),
              ),
              Container(height: 1.5, color: Colors.white),
              Expanded(
                child: _buildImage(count > 2 ? recipes[2].image : null),
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
