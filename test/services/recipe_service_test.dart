import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cooked/services/recipe_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('RecipeService cache is cleared on logout or clearCache', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('persistent_cache_v2_test_key', '{"timestamp":123,"data":[]}');

    RecipeService.instance.clearCache();

    // Since clearCache has async shared_prefs internally, wait a bit
    await Future.delayed(const Duration(milliseconds: 100));

    expect(prefs.containsKey('persistent_cache_v2_test_key'), false);
  });
}
