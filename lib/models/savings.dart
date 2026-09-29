import 'recipe.dart';

/// Savings computed by the backend (`GET /recipes/savings`) from scanned
/// recipes only. The app just displays it - never recompute it locally.
class SavingsSummary {
  final double totalSaved;
  final int recipeCount;
  final List<SavingsItem> recipes;

  const SavingsSummary({
    required this.totalSaved,
    required this.recipeCount,
    required this.recipes,
  });

  factory SavingsSummary.fromJson(Map<String, dynamic> json) {
    final items = (json['recipes'] as List<dynamic>? ?? [])
        .map((e) => SavingsItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return SavingsSummary(
      totalSaved: (json['totalSaved'] as num?)?.toDouble() ?? 0.0,
      recipeCount: (json['recipeCount'] as num?)?.toInt() ?? items.length,
      recipes: items,
    );
  }
}

class SavingsItem {
  final Recipe recipe;
  final double savings;
  final String displayName;

  const SavingsItem({
    required this.recipe,
    required this.savings,
    required this.displayName,
  });

  factory SavingsItem.fromJson(Map<String, dynamic> json) {
    final recipe = Recipe.fromJson(json['recipe'] as Map<String, dynamic>);
    return SavingsItem(
      recipe: recipe,
      savings: (json['savings'] as num?)?.toDouble() ?? 0.0,
      displayName: json['displayName']?.toString() ?? recipe.name,
    );
  }
}
