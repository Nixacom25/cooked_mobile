import 'package:flutter/material.dart';
import 'package:app_ecommerce/models/category.dart';
import 'package:app_ecommerce/utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CategoryItem extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryItem({
    super.key,
    required this.category,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        width: 70, // Fixed width for alignment
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryLight, // Dark circle
                image: category.imageUrl.isNotEmpty
                    ? DecorationImage(
                        image: CachedNetworkImageProvider(
                          category.imageUrl,
                          maxWidth: 120, // 2x for retina
                          maxHeight: 120,
                        ),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: category.imageUrl.isEmpty
                  ? const Icon(Icons.category, color: Colors.white54)
                  : null,
            ),
            const SizedBox(height: 4),
            Text(
              category.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11, // Reduced font size slightly
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.accent : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
