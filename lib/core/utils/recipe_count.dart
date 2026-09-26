String recipeCountLabel(Object? count, {bool capitalize = false}) {
  final n = count is num ? count.toInt() : int.tryParse('$count') ?? 0;
  final word = n >= 2 ? 'recipes' : 'recipe';
  return '$n ${capitalize ? '${word[0].toUpperCase()}${word.substring(1)}' : word}';
}
