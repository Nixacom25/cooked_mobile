import 'package:flutter_test/flutter_test.dart';
import 'package:cooked/core/utils/app_link.dart';

void main() {
  test('recipe links (web and app scheme)', () {
    expect(AppLink.parse('https://link.cookedapp.com/share/recipes/abc-123'),
        isA<RecipeLink>().having((l) => l.recipeId, 'id', 'abc-123'));
    expect(AppLink.parse('cooked://recipe/abc-123'), isA<RecipeLink>());
  });

  test('cookbook links', () {
    expect(AppLink.parse('https://link.cookedapp.com/share/cookbooks/cb-1'),
        isA<CookbookLink>().having((l) => l.cookbookId, 'id', 'cb-1'));
    expect(AppLink.parse('cooked://cookbook/cb-1'), isA<CookbookLink>());
  });

  test('email utility links', () {
    expect(AppLink.parse('https://link.cookedapp.com/security'),
        isA<UtilityLink>().having((l) => l.target, 'target', 'security'));
  });

  test('external pages are web links, custom schemes are not', () {
    expect(AppLink.parse('https://www.instagram.com/reel/xyz/?igsh=1'), isA<WebLink>());
    expect(AppLink.parse('cooked://payment?status=ok'), isA<UnsupportedLink>());
    expect(AppLink.parse('/private/var/mobile/thumb.jpg'), isA<UnsupportedLink>());
  });
}
