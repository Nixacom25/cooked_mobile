import 'package:flutter/material.dart';
import 'package:app_ecommerce/models/product.dart';
import 'package:app_ecommerce/utils/constants.dart';
import 'package:app_ecommerce/widgets/dark_product_card.dart';

class CategorySection extends StatelessWidget {
  final String title;
  final String? imageUrl; // Changed from IconData icon
  final List<Product> products;
  final VoidCallback onTapSeeMore;
  final Function(Product) onProductTap;

  const CategorySection({
    super.key,
    required this.title,
    this.imageUrl,
    required this.products,
    required this.onTapSeeMore,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title[0].toUpperCase() + title.substring(1),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900, // Extra bold as in mockup
                    color: Color(0xFF1E1E2C),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onTapSeeMore,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7F0), // Ultra light peach
                    borderRadius: BorderRadius.circular(20), // Pill shape
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'VOIR PLUS',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5, // Sharper spacing
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.chevron_right,
                        color: AppColors.accent,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 250,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding,
            ),
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return DarkProductCard(
                product: product,
                onTap: () => onProductTap(product),
              );
            },
          ),
        ),
      ],
    );
  }
}
