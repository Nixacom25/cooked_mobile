import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cooked/services/recipe_service.dart';
import 'package:cooked/services/database_service.dart';
import 'package:cooked/models/recipe.dart';
import 'dart:io';

Map<String, dynamic> _recipeJson(String id, {String? image}) => {
      'id': id,
      'name': 'Creamy Pumpkin Ravioli',
      'image': image,
      'cookTime': 10,
      'kcal': 300,
      'steps': <String>[],
      'equipment': <String>[],
      'ingredients': <Map<String, dynamic>>[],
      'isPublic': false,
      'isFavorite': false,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    final tempPath = Directory.systemTemp.createTempSync('hive_test').path;
    Hive.init(tempPath);
    await Hive.openBox<String>(DatabaseService.cacheBoxName);
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
  });

  test('RecipeService cache is cleared on clearCache', () async {
    await DatabaseService.instance.writeCacheRaw('persistent_cache_v3_test', 'some_data');

    expect(DatabaseService.instance.readCacheRaw('persistent_cache_v3_test'), 'some_data');

    await RecipeService.instance.clearCache();

    expect(DatabaseService.instance.readCacheRaw('persistent_cache_v3_test'), null);
  });

  test(
    'a recipe saved with no AI photo yet gets its image filled in once the backend finishes generating it',
    () async {
      const imageUrl = 'https://cdn.cookedapp.com/recipes/r1.jpg';

      final mockClient = MockClient((request) async {
        if (request.method == 'POST' && request.url.path == '/recipes') {
          // Just created: the AI photo hasn't been generated yet.
          return http.Response(jsonEncode(_recipeJson('r1')), 201);
        }
        if (request.method == 'GET' && request.url.path == '/recipes') {
          return http.Response(
            jsonEncode([_recipeJson('r1')]),
            200,
          );
        }
        if (request.method == 'GET' && request.url.path == '/recipes/r1') {
          // The background poll checks again later: the photo is ready now.
          return http.Response(jsonEncode(_recipeJson('r1', image: imageUrl)), 200);
        }
        return http.Response('not found', 404);
      });

      await http.runWithClient(() async {
        RecipeService.instance.myRecipesNotifier.value = [];

        final saved = await RecipeService.instance.createRecipe(
          Recipe(
            id: '',
            name: 'Creamy Pumpkin Ravioli',
            cookTime: 10,
            kcal: 300,
            steps: const [],
            equipment: const [],
            ingredients: const [],
            isPublic: false,
            isFavorite: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        expect(saved.image, isNull, reason: 'backend has not generated the photo yet');

        // Past the first 5s poll tick, where the mock backend now has the photo.
        await Future.delayed(const Duration(seconds: 6));

        final updated = RecipeService.instance.myRecipesNotifier.value!
            .firstWhere((r) => r.id == 'r1');
        expect(updated.image, imageUrl);
      }, () => mockClient);
    },
    timeout: const Timeout(Duration(seconds: 30)),
  );
}
