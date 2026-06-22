import 'package:flutter/foundation.dart';

class Recipe {
  final String id;
  final String name;
  final String? image;
  final int cookTime;
  final int? prepTime;
  final int kcal;
  final List<String> steps;
  final List<String> equipment;
  final List<RecipeIngredient> ingredients;
  bool isPublic;
  bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String>? categories;
  final RecipeCreator? creator;
  final String? sourceUrl;
  final int? servings;
  final String? tips;
  final DateTime? expiresAt;
  final String? origin;
  final String? cuisine;
  final bool isSuggested;
  final bool isInCookbook;
  final bool isPinned;
  final bool isValidated;
  final bool isPlaceholder;
  final double? totalPrice;
  final int? ingredientsCount;

  Recipe({
    required this.id,
    required this.name,
    this.image,
    required this.cookTime,
    this.prepTime,
    required this.kcal,
    required this.steps,
    required this.equipment,
    required this.ingredients,
    required this.isPublic,
    required this.isFavorite,
    required this.createdAt,
    required this.updatedAt,
    this.categories,
    this.creator,
    this.sourceUrl,
    this.servings,
    this.tips,
    this.expiresAt,
    this.origin,
    this.cuisine,
    this.isSuggested = false,
    this.isInCookbook = false,
    this.isPinned = false,
    this.isValidated = false,
    this.isPlaceholder = false,
    this.totalPrice,
    this.ingredientsCount,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    try {
      final stepsList = (json['steps'] as List?)?.map((e) => e.toString()).toList() ?? [];
      final equipmentList = (json['equipment'] as List?)?.map((e) => e.toString()).toList() ?? [];
      debugPrint('📦 [Recipe.fromJson] parsing ${json['name']}: steps=${stepsList.length}, equipment=${equipmentList.length}');

      String? cleanImage;
      if (json['image'] != null) {
        cleanImage = json['image'].toString().replaceAll('"', '').trim();
        if (cleanImage.isEmpty) cleanImage = null;
      }

      return Recipe(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? 'Recipe',
        image: cleanImage,
        cookTime: (json['cookTime'] as num?)?.toInt() ?? 0,
        kcal: (json['kcal'] as num?)?.toInt() ?? 0,
        steps: stepsList,
        equipment: equipmentList,
        ingredients: (json['ingredients'] as List? ?? [])
            .where((i) => i != null)
            .map((i) => RecipeIngredient.fromJson(Map<String, dynamic>.from(i)))
            .toList(),
        isPublic: json['isPublic'] ?? json['public'] ?? false,
        isFavorite: json['isFavorite'] ?? json['favorite'] ?? false,
        createdAt: json['createdAt'] != null
            ? (DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now())
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? (DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now())
            : DateTime.now(),
        categories: json['categories'] != null ? List<String>.from(json['categories']) : null,
        creator: json['creator'] != null
            ? RecipeCreator.fromJson(Map<String, dynamic>.from(json['creator']))
            : null,
        sourceUrl: json['sourceUrl']?.toString(),
        servings: (json['servings'] as num?)?.toInt(),
        tips: json['tips']?.toString(),
        prepTime: (json['prepTime'] as num?)?.toInt(),
        expiresAt: json['expiresAt'] != null
            ? DateTime.tryParse(json['expiresAt'].toString())
            : null,
        origin: json['origin']?.toString(),
        cuisine: json['cuisine']?.toString(),
        isSuggested: json['isSuggested'] ?? json['is_suggested'] ?? (json['expiresAt'] != null),
        isInCookbook: json['isInCookbook'] ?? json['inCookbook'] ?? false,
        isPinned: json['isPinned'] ?? json['is_pinned'] ?? json['pinned'] ?? false,
        isValidated: json['isValidated'] ?? json['isValidated'] ?? false,
        isPlaceholder: json['isPlaceholder'] ?? false,
        totalPrice: (json['totalPrice'] as num?)?.toDouble(),
        ingredientsCount: (json['ingredientsCount'] as num?)?.toInt(),
      );
    } catch (e) {
      return Recipe(
        id: json['id']?.toString() ?? 'error',
        name: json['name']?.toString() ?? 'Error loading',
        cookTime: 0,
        kcal: 0,
        steps: [],
        equipment: [],
        ingredients: [],
        isPublic: false,
        isFavorite: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isPlaceholder: true,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'cookTime': cookTime,
      'kcal': kcal,
      'steps': steps,
      'equipment': equipment,
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
      'isPublic': isPublic,
      'isFavorite': isFavorite,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'categories': categories,
      'creator': creator?.toJson(),
      'sourceUrl': sourceUrl,
      'servings': servings,
      'tips': tips,
      'prepTime': prepTime,
      'expiresAt': expiresAt?.toIso8601String(),
      'origin': origin,
      'cuisine': cuisine,
      'isSuggested': isSuggested,
      'isInCookbook': isInCookbook,
      'isPinned': isPinned,
      'isValidated': isValidated,
      'isPlaceholder': isPlaceholder,
      'totalPrice': totalPrice,
      'ingredientsCount': ingredientsCount,
    };
  }

  Recipe copyWith({
    String? id,
    String? name,
    String? image,
    int? cookTime,
    int? prepTime,
    int? kcal,
    List<String>? steps,
    List<String>? equipment,
    List<RecipeIngredient>? ingredients,
    bool? isPublic,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? categories,
    RecipeCreator? creator,
    String? sourceUrl,
    int? servings,
    String? tips,
    DateTime? expiresAt,
    String? origin,
    String? cuisine,
    bool? isSuggested,
    bool? isInCookbook,
    bool? isPinned,
    bool? isValidated,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      cookTime: cookTime ?? this.cookTime,
      prepTime: prepTime ?? this.prepTime,
      kcal: kcal ?? this.kcal,
      steps: steps ?? this.steps,
      equipment: equipment ?? this.equipment,
      ingredients: ingredients ?? this.ingredients,
      isPublic: isPublic ?? this.isPublic,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      categories: categories ?? this.categories,
      creator: creator ?? this.creator,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      servings: servings ?? this.servings,
      tips: tips ?? this.tips,
      expiresAt: expiresAt ?? this.expiresAt,
      origin: origin ?? this.origin,
      cuisine: cuisine ?? this.cuisine,
      isSuggested: isSuggested ?? this.isSuggested,
      isInCookbook: isInCookbook ?? this.isInCookbook,
      isPinned: isPinned ?? this.isPinned,
      isValidated: isValidated ?? this.isValidated,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Recipe && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstname': firstname,
      'lastname': lastname,
      'photo': photo,
    };
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
  final String? image;
  final double? price;

  RecipeIngredient({
    required this.id,
    required this.name,
    required this.amount,
    required this.unit,
    required this.quantity,
    this.icon,
    this.image,
    this.price,
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
      image: json['image'],
      price: (json['price'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'unit': unit,
      'quantity': quantity,
      'icon': icon,
      'image': image,
      'price': price,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeIngredient && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
