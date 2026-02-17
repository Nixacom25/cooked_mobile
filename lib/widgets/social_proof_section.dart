import 'package:flutter/material.dart';
import 'package:app_ecommerce/utils/constants.dart';
import 'dart:math';
import 'package:app_ecommerce/screens/status_view_screen.dart';
import 'package:app_ecommerce/models/status_category.dart';
import 'package:app_ecommerce/models/testimonial.dart';

import 'package:app_ecommerce/models/category.dart'; // Added import

class SocialProofSection extends StatelessWidget {
  final List<Testimonial> testimonials;
  final List<Category> categories; // Added

  const SocialProofSection({
    super.key,
    required this.testimonials,
    this.categories = const [], // Default empty
  });

  List<StatusCategory> _getGroupedStatuses() {
    final Map<String, List<Testimonial>> grouped = {};

    for (var t in testimonials) {
      if (!grouped.containsKey(t.category)) {
        grouped[t.category] = [];
      }
      grouped[t.category]!.add(t);
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
    // Filter categories that have items
    final categories = _getGroupedStatuses()
        .where((c) => c.items.isNotEmpty)
        .toList();

    if (categories.isEmpty) {
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
              const Icon(
                Icons.check_circle_outline,
                color: Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'CLIENTS LIVRÉS PARTOUT AU SÉNÉGAL',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding,
            ),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return _buildStatusItem(context, categories, index);
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
            opaque: false, // Transparent background transition potentially
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
        width: 80,
        child: Column(
          children: [
            CustomPaint(
              painter: StatusBorderPainter(
                itemCount: category.items.length,
                color: const Color(0xFF2E7D32), // WhatsApp Green
                strokeWidth: 2.0,
                gapSize: 0.2, // Gap in radians
              ),
              child: Container(
                padding: const EdgeInsets.all(
                  4,
                ), // Space between border and avatar
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: NetworkImage(category.avatarUrl),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatusBorderPainter extends CustomPainter {
  final int itemCount;
  final Color color;
  final double strokeWidth;
  final double gapSize; // Gap size in radians

  StatusBorderPainter({
    required this.itemCount,
    required this.color,
    this.strokeWidth = 2.0,
    this.gapSize = 0.2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    if (itemCount == 1) {
      canvas.drawCircle(center, radius, paint);
    } else {
      final double totalGap = gapSize * itemCount;
      final double totalSweep = 2 * pi - totalGap;
      final double sweepAngle = totalSweep / itemCount;

      double startAngle = -pi / 2; // Start from top

      for (int i = 0; i < itemCount; i++) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          false,
          paint,
        );
        startAngle += sweepAngle + gapSize;
      }
    }
  }

  @override
  bool shouldRepaint(covariant StatusBorderPainter oldDelegate) {
    return oldDelegate.itemCount != itemCount;
  }
}
