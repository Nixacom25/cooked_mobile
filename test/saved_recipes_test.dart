import 'package:cooked/models/recipe.dart';
import 'package:cooked/services/recipe_service.dart';
import 'package:flutter_test/flutter_test.dart';

Recipe _r(String id, {bool placeholder = false, bool suggested = false, bool inCookbook = false}) => Recipe(
      id: id,
      name: 'Recipe $id',
      cookTime: 10,
      kcal: 100,
      steps: const [],
      equipment: const [],
      ingredients: const [],
      isPublic: false,
      isFavorite: false,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
      isPlaceholder: placeholder,
      isSuggested: suggested,
      isInCookbook: inCookbook,
    );

void main() {
  test('Saved Recipes keeps real recipes (also those in a cookbook)', () {
    final saved = RecipeService.savedRecipesOf([
      _r('1'),
      _r('2', inCookbook: true),
      _r('3', placeholder: true),
      _r('4', suggested: true),
    ]);
    expect(saved.map((r) => r.id), ['1', '2']);
    expect(RecipeService.savedRecipesOf(null), isEmpty);
  });
}
