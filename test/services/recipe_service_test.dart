import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cooked/services/recipe_service.dart';
import 'package:cooked/services/database_service.dart';
import 'dart:io';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    final tempPath = Directory.systemTemp.createTempSync('hive_test').path;
    Hive.init(tempPath);
    await Hive.openBox<String>(DatabaseService.cacheBoxName);
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
}
