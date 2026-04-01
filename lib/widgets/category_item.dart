import 'package:flutter/material.dart';
import 'package:app_ecommerce/models/category.dart';
import 'package:app_ecommerce/utils/constants.dart';
import 'package:app_ecommerce/utils/url_sanitizer.dart';

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
    final hasImage = category.imageUrl.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 15),
        width: 60,
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[100],
                image: hasImage
                    ? DecorationImage(
                        image: UrlSanitizer.buildImageProvider(
                          category.imageUrl,
                        ),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: !hasImage
                  ? const Icon(Icons.category, color: Colors.grey, size: 20)
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.accent : const Color(0xFF2D3E50),
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
