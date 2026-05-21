import 'recipe.dart';

class Cookbook {
  final String id;
  final String name;
  final List<Recipe> recipes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPlaceholder;
  final bool isPinned;

  Cookbook({
    required this.id,
    required this.name,
    required this.recipes,
    required this.createdAt,
    required this.updatedAt,
    this.isPlaceholder = false,
    this.isPinned = false,
  });

  factory Cookbook.fromJson(Map<String, dynamic> json) {
    try {
      return Cookbook(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? 'Untitled',
        recipes: (json['recipes'] as List? ?? [])
            .where((r) => r != null)
            .map((r) => Recipe.fromJson(Map<String, dynamic>.from(r)))
            .toList(),
        createdAt: json['createdAt'] != null
            ? (DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now())
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? (DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now())
            : DateTime.now(),
        isPinned: json['isPinned'] ?? json['is_pinned'] ?? json['pinned'] ?? false,
      );
    } catch (e) {
      // Return a minimal valid object if parsing fails completely for one item
      return Cookbook(
        id: json['id']?.toString() ?? 'error',
        name: json['name']?.toString() ?? 'Error loading',
        recipes: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }
}
