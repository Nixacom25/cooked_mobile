class Recipe {
  final String id;
  final String name;
  final String? image;
  final int cookTime;
  final int kcal;
  final List<String> steps;
  final List<RecipeIngredient> ingredients;
  bool isPublic;
  bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? category;
  final RecipeCreator? creator;
  final String? sourceUrl;
  final int? servings;
  final String? tips;

  Recipe({
    required this.id,
    required this.name,
    this.image,
    required this.cookTime,
    required this.kcal,
    required this.steps,
    required this.ingredients,
    required this.isPublic,
    required this.isFavorite,
    required this.createdAt,
    required this.updatedAt,
    this.category,
    this.creator,
    this.sourceUrl,
    this.servings,
    this.tips,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Recipe',
      image: json['image'],
      cookTime: json['cookTime'] ?? 0,
      kcal: json['kcal'] ?? 0,
      steps: List<String>.from(json['steps'] ?? []),
      ingredients: (json['ingredients'] as List? ?? [])
          .map((i) => RecipeIngredient.fromJson(i))
          .toList(),
      isPublic: json['public'] ?? false,
      isFavorite: json['favorite'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      category: json['category'],
      creator: json['creator'] != null
          ? RecipeCreator.fromJson(json['creator'])
          : null,
      sourceUrl: json['sourceUrl'],
      servings: json['servings'],
      tips: json['tips'],
    );
  }
}

class RecipeCreator {
  final String id;
  final String firstname;
  final String lastname;
  final String? photo;

  RecipeCreator({
    required this.id,
    required this.firstname,
    required this.lastname,
    this.photo,
  });

  factory RecipeCreator.fromJson(Map<String, dynamic> json) {
    return RecipeCreator(
      id: json['id'] ?? '',
      firstname: json['firstname'] ?? '',
      lastname: json['lastname'] ?? '',
      photo: json['photo'],
    );
  }

  String get displayName => '$firstname $lastname';
}

class RecipeIngredient {
  final String id;
  final String name;
  final double amount;
  final String unit;
  final String quantity;
  final String? icon;

  RecipeIngredient({
    required this.id,
    required this.name,
    required this.amount,
    required this.unit,
    required this.quantity,
    this.icon,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    // Clean text only, no icons per requirements
    double amount = 0.0;
    String unit = '';
    String quantity = '';

    if (json['quantity'] != null) {
      quantity = json['quantity'].toString();
      // Try to parse quantity like "2 cups" or "250g"
      final match = RegExp(r'^(\d+\.?\d*)\s*(.*)$').firstMatch(quantity);
      if (match != null) {
        amount = double.tryParse(match.group(1) ?? '0') ?? 0.0;
        unit = match.group(2) ?? '';
      } else {
        unit = quantity;
      }
    } else if (json['amount'] != null) {
      amount = (json['amount'] as num?)?.toDouble() ?? 0.0;
      unit = json['unit'] ?? '';
      quantity = unit.isEmpty ? amount.toString() : '$amount $unit';
    }

    return RecipeIngredient(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      amount: amount,
      unit: unit,
      quantity: quantity.isEmpty ? '1' : quantity,
      icon: json['icon'], 
    );
  }
}
