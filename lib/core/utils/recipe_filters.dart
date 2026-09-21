import '../../models/recipe.dart';

/// One quick-filter chip: a label, an emoji, and a predicate that decides
/// whether a given recipe belongs to it. Predicates run entirely on data
/// already present on a fetched Recipe (name, categories, cuisine, macros,
/// ingredients, steps/equipment, price) - no extra network calls needed.
class RecipeFilterDef {
  final String id;
  final String label;
  final String emoji;
  final bool Function(Recipe recipe) matches;

  const RecipeFilterDef({
    required this.id,
    required this.label,
    required this.emoji,
    required this.matches,
  });
}

bool _textHasAny(String text, List<String> keywords) {
  final lower = text.toLowerCase();
  return keywords.any((k) => lower.contains(k));
}

bool _categoriesOrNameHasAny(Recipe r, List<String> keywords) {
  if (_textHasAny(r.name, keywords)) return true;
  final cats = r.categories;
  if (cats == null) return false;
  return cats.any((c) => _textHasAny(c, keywords));
}

bool _ingredientsHaveAny(Recipe r, List<String> keywords) {
  return r.ingredients.any((ing) => _textHasAny(ing.name, keywords));
}

const _meatSeafoodKeywords = [
  'chicken', 'beef', 'pork', 'turkey', 'lamb', 'bacon', 'sausage', 'ham',
  'salmon', 'tuna', 'shrimp', 'fish', 'crab', 'lobster', 'anchovy', 'squid',
];

const _animalProductKeywords = [
  ..._meatSeafoodKeywords,
  'egg', 'milk', 'cheese', 'butter', 'cream', 'yogurt', 'honey', 'gelatin',
];

const _cookVerbs = [
  'bake', 'cook', 'fry', 'boil', 'grill', 'roast', 'simmer', 'sauté',
  'saute', 'sear', 'steam', 'broil', 'preheat', 'oven', 'stovetop',
];

final List<RecipeFilterDef> kRecipeFilters = [
  RecipeFilterDef(
    id: 'high_protein',
    label: 'High Protein',
    emoji: '💪',
    // No macro (grams of protein) data is tracked per recipe today, so this
    // falls back to a category tag or a protein-forward main ingredient as
    // the closest available proxy for "~30g+ protein per serving".
    matches: (r) =>
        _categoriesOrNameHasAny(r, ['high protein', 'protein']) ||
        _ingredientsHaveAny(r, ['chicken breast', 'egg', 'tofu', 'salmon', 'steak', 'lentil', 'chickpea', 'greek yogurt']),
  ),
  RecipeFilterDef(
    id: 'under_30_min',
    label: 'Under 30 Min',
    emoji: '⏱️',
    matches: (r) => (r.cookTime + (r.prepTime ?? 0)) <= 30,
  ),
  RecipeFilterDef(
    id: 'breakfast',
    label: 'Breakfast',
    emoji: '🍳',
    matches: (r) => _categoriesOrNameHasAny(r, [
      'breakfast', 'egg', 'pancake', 'oat', 'waffle', 'smoothie bowl', 'granola',
    ]),
  ),
  RecipeFilterDef(
    id: 'lunch',
    label: 'Lunch',
    emoji: '🥪',
    matches: (r) => _categoriesOrNameHasAny(r, [
      'lunch', 'sandwich', 'wrap', 'salad', 'bowl',
    ]),
  ),
  RecipeFilterDef(
    id: 'dinner',
    label: 'Dinner',
    emoji: '🍽️',
    matches: (r) => _categoriesOrNameHasAny(r, ['dinner', 'entrée', 'entree', 'main dish', 'main course']),
  ),
  RecipeFilterDef(
    id: 'low_calorie',
    label: 'Low Calorie',
    emoji: '⚖️',
    matches: (r) => r.kcal > 0 && r.kcal <= 500,
  ),
  RecipeFilterDef(
    id: 'one_pot',
    label: 'One-Pot',
    emoji: '🍲',
    matches: (r) => _textHasAny(r.name, ['one pot', 'one-pot', 'sheet pan', 'skillet']) ||
        r.equipment.any((e) => _textHasAny(e, ['sheet pan', 'skillet', 'dutch oven', 'one pot', 'one-pot'])),
  ),
  RecipeFilterDef(
    id: 'budget_friendly',
    label: 'Budget Friendly',
    emoji: '💰',
    // Proxy: total ingredient cost per serving stays low.
    matches: (r) {
      if (r.totalPrice == null || r.totalPrice! <= 0) return false;
      final servings = (r.servings ?? 1).clamp(1, 999);
      return (r.totalPrice! / servings) <= 4.0;
    },
  ),
  RecipeFilterDef(
    id: 'vegetarian',
    label: 'Vegetarian',
    emoji: '🥦',
    matches: (r) => !_ingredientsHaveAny(r, _meatSeafoodKeywords),
  ),
  RecipeFilterDef(
    id: 'vegan',
    label: 'Vegan',
    emoji: '🌱',
    matches: (r) => !_ingredientsHaveAny(r, _animalProductKeywords),
  ),
  RecipeFilterDef(
    id: 'no_cook',
    label: 'No-Cook',
    emoji: '🧊',
    matches: (r) =>
        _textHasAny(r.name, ['no-cook', 'no cook', 'overnight']) ||
        (r.steps.isNotEmpty && !r.steps.any((s) => _textHasAny(s, _cookVerbs))),
  ),
  RecipeFilterDef(
    id: 'desserts',
    label: 'Desserts',
    emoji: '🍰',
    matches: (r) => _categoriesOrNameHasAny(r, [
      'dessert', 'cake', 'cookie', 'brownie', 'pudding', 'pie', 'sweet',
    ]),
  ),
  RecipeFilterDef(
    id: 'snacks',
    label: 'Snacks',
    emoji: '🍿',
    matches: (r) => _categoriesOrNameHasAny(r, ['snack']),
  ),
  RecipeFilterDef(
    id: 'smoothies',
    label: 'Smoothies',
    emoji: '🥤',
    matches: (r) => _categoriesOrNameHasAny(r, ['smoothie', 'shake', 'protein shake']),
  ),
  RecipeFilterDef(
    id: 'salads',
    label: 'Salads',
    emoji: '🥗',
    matches: (r) => _categoriesOrNameHasAny(r, ['salad']),
  ),
  RecipeFilterDef(
    id: 'soups',
    label: 'Soups',
    emoji: '🍜',
    matches: (r) => _categoriesOrNameHasAny(r, ['soup', 'stew', 'bisque', 'chili']),
  ),
  RecipeFilterDef(
    id: 'pasta',
    label: 'Pasta',
    emoji: '🍝',
    matches: (r) => _categoriesOrNameHasAny(r, ['pasta', 'noodle', 'spaghetti', 'macaroni', 'penne', 'lasagna']),
  ),
  RecipeFilterDef(
    id: 'bowls',
    label: 'Bowls',
    emoji: '🍛',
    matches: (r) => _categoriesOrNameHasAny(r, ['bowl']),
  ),
  RecipeFilterDef(
    id: 'sandwiches_wraps',
    label: 'Sandwiches & Wraps',
    emoji: '🌯',
    matches: (r) => _categoriesOrNameHasAny(r, ['sandwich', 'wrap', 'sub', 'panini', 'taco']),
  ),
  RecipeFilterDef(
    id: 'chicken',
    label: 'Chicken',
    emoji: '🍗',
    matches: (r) => _ingredientsHaveAny(r, ['chicken']) || _textHasAny(r.name, ['chicken']),
  ),
  RecipeFilterDef(
    id: 'beef',
    label: 'Beef',
    emoji: '🥩',
    matches: (r) => _ingredientsHaveAny(r, ['beef', 'steak', 'ground beef']) || _textHasAny(r.name, ['beef', 'steak']),
  ),
  RecipeFilterDef(
    id: 'seafood',
    label: 'Seafood',
    emoji: '🦐',
    matches: (r) => _ingredientsHaveAny(r, ['fish', 'shrimp', 'crab', 'salmon', 'tuna', 'lobster', 'squid']) ||
        _textHasAny(r.name, ['fish', 'shrimp', 'crab', 'salmon', 'tuna', 'seafood']),
  ),
];

RecipeFilterDef? findRecipeFilter(String id) {
  for (final f in kRecipeFilters) {
    if (f.id == id) return f;
  }
  return null;
}
