import '../l10n/l10n.dart';

/// "1 recipe", "12 recipes" (or "12 Recipes" in titles), in the UI language.
String recipeCountLabel(AppLocalizations l10n, Object? count, {bool capitalize = false}) {
  final n = count is num ? count.toInt() : int.tryParse('$count') ?? 0;
  return capitalize ? l10n.recipeCountTitle(n) : l10n.recipeCount(n);
}
