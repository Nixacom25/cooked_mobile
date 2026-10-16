/// What a link opened in / shared to the app points to. Shared by the deep
/// link router (main.dart) and the Import tab, so both agree on which links
/// are Cooked's own (opened in-app) and which are web pages to import.
sealed class AppLink {
  const AppLink();

  static final _recipe = RegExp(
    r'(?:(?:cooked\.nixacom\.com|cookedapp\.com)/(?:share/)?recipes/|cooked://recipe/)([a-zA-Z0-9-]+)',
  );
  static final _cookbook = RegExp(
    r'(?:(?:cooked\.nixacom\.com|cookedapp\.com)/share/cookbooks/|cooked://cookbook/)([a-zA-Z0-9-]+)',
  );
  // Utility links used by transactional emails (Welcome, billing issue,
  // new sign-in).
  static final _utility = RegExp(
    r'(?:cooked://|link\.cookedapp\.com/)(open|manage-subscription|security)\b',
  );

  /// [url] must already be extracted from the shared text.
  static AppLink parse(String url) {
    final utility = _utility.firstMatch(url);
    if (utility != null) return UtilityLink(utility.group(1)!);

    final cookbook = _cookbook.firstMatch(url);
    if (cookbook != null) return CookbookLink(cookbook.group(1)!);

    final recipe = _recipe.firstMatch(url);
    if (recipe != null) return RecipeLink(recipe.group(1)!);

    final uri = Uri.tryParse(url);
    final isWeb = uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    return isWeb ? WebLink(url) : const UnsupportedLink();
  }
}

class RecipeLink extends AppLink {
  final String recipeId;
  const RecipeLink(this.recipeId);
}

class CookbookLink extends AppLink {
  final String cookbookId;
  const CookbookLink(this.cookbookId);
}

class UtilityLink extends AppLink {
  /// `open`, `manage-subscription` or `security`.
  final String target;
  const UtilityLink(this.target);
}

/// An external web page (Instagram, TikTok, a recipe site…) to import.
class WebLink extends AppLink {
  final String url;
  const WebLink(this.url);
}

/// Anything else (a custom scheme we don't handle, a malformed link…).
class UnsupportedLink extends AppLink {
  const UnsupportedLink();
}
