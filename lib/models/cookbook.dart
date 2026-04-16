import 'recipe.dart';

class Cookbook {
  final String id;
  final String name;
  final List<Recipe> recipes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Cookbook({
    required this.id,
    required this.name,
    required this.recipes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Cookbook.fromJson(Map<String, dynamic> json) {
    return Cookbook(
      id: json['id'],
      name: json['name'],
      recipes: (json['recipes'] as List? ?? [])
          .map((r) => Recipe.fromJson(r))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
