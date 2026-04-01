import 'package:flutter/material.dart';
import 'package:app_ecommerce/utils/constants.dart';
import 'package:app_ecommerce/screens/status_view_screen.dart';
import 'package:app_ecommerce/models/status_category.dart';
import 'package:app_ecommerce/models/testimonial.dart';
import 'package:app_ecommerce/models/category.dart';
import 'package:app_ecommerce/utils/url_sanitizer.dart';

class SocialProofSection extends StatelessWidget {
  final List<Testimonial> testimonials;
  final List<Category> categories;

  const SocialProofSection({
    super.key,
    required this.testimonials,
    this.categories = const [],
  });

  List<StatusCategory> _getGroupedStatuses() {
    final Map<String, List<Testimonial>> grouped = {};

    for (var t in testimonials) {
      final key = t.categoryName ?? 'Autres';
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(t);
    }

    return grouped.entries.map((entry) {
      final categoryName = entry.key;
      final items = entry.value;

      // Default avatar
      String avatarUrl =
          'https://ui-avatars.com/api/?name=$categoryName&background=random';

      // Try to find matching category image
      try {
        final category = categories.firstWhere(
          (c) =>
              c.name.trim().toLowerCase() == categoryName.trim().toLowerCase(),
        );
        if (category.imageUrl.isNotEmpty) {
          avatarUrl = category.imageUrl;
        }
      } catch (_) {}

      return StatusCategory(
        id: categoryName,
        name: categoryName,
        avatarUrl: avatarUrl,
        items: items,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesList = _getGroupedStatuses()
        .where((c) => c.items.isNotEmpty)
        .toList();

    if (categoriesList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(1),
                decoration: const BoxDecoration(
                  color: Color(0xFFFF7144),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 12,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'CLIENTS LIVRÉS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF000000),
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 115,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding,
            ),
            scrollDirection: Axis.horizontal,
            itemCount: categoriesList.length,
            itemBuilder: (context, index) {
              return _buildStatusItem(context, categoriesList, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatusItem(
    BuildContext context,
    List<StatusCategory> categories,
    int index,
  ) {
    final category = categories[index];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            opaque: false,
            settings: const RouteSettings(name: '/status_view'),
            pageBuilder: (_, __, ___) => StatusViewScreen(
              allCategories: categories,
              initialCategoryIndex: index,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 15),
        width: 60,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [
                    Color(0xFFFCAF45),
                    Color(0xFFF56040),
                    Color(0xFFE1306C),
                  ],
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.grey[100],
                  backgroundImage: UrlSanitizer.buildImageProvider(
                    category.avatarUrl,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1E2C),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
