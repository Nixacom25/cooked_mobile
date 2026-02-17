import 'package:app_ecommerce/models/testimonial.dart';

class StatusCategory {
  final String id;
  final String name;
  final String avatarUrl;
  final List<Testimonial> items; // The statuses in this category

  const StatusCategory({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.items,
  });
}
