import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';

class DatabaseService {
  DatabaseService._privateConstructor();
  static final DatabaseService instance = DatabaseService._privateConstructor();

  static const String cacheBoxName = 'cache_box_v3';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(cacheBoxName);
  }

  Box<String> get cacheBox {
    return Hive.box<String>(cacheBoxName);
  }

  Future<void> writeCache(String key, dynamic data) async {
    try {
      final cacheData = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'data': data,
      };
      await cacheBox.put(key, jsonEncode(cacheData));
    } catch (e) {
      debugPrint('Hive write error: $e');
    }
  }

  dynamic readCache(String key, Duration ttl) {
    try {
      final String? jsonStr = cacheBox.get(key);
      if (jsonStr == null) return null;

      final decoded = jsonDecode(jsonStr);
      final int timestamp = decoded['timestamp'] as int;
      final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      
      if (DateTime.now().difference(cachedTime) > ttl) {
        cacheBox.delete(key);
        return null;
      }
      return decoded['data'];
    } catch (e) {
      return null;
    }
  }

  Future<void> writeCacheRaw(String key, String jsonData) async {
    await cacheBox.put(key, jsonData);
  }

  String? readCacheRaw(String key) {
    return cacheBox.get(key);
  }

  Future<void> clearCache() async {
    await cacheBox.clear();
  }
}
