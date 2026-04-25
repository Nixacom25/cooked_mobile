import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe.dart';
import '../services/user_service.dart';


class HistoryService {
  HistoryService._privateConstructor() {
    // Automatically reload history when user changes
    UserService.instance.currentUserNotifier.addListener(() {
      loadHistory();
    });
  }
  static final HistoryService instance = HistoryService._privateConstructor();

  static const String _baseKey = 'recently_viewed_recipes';

  String _getKey() {
    final user = UserService.instance.currentUserNotifier.value;
    final userId = user != null ? (user['id']?.toString() ?? 'guest') : 'guest';
    return '${_baseKey}_$userId';
  }

  final ValueNotifier<List<Recipe>> recentlyViewedNotifier = ValueNotifier([]);

  Future<void> init() async {
    await loadHistory();
  }

  void clearData() {
    recentlyViewedNotifier.value = [];
  }

  Future<void> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? jsonList = prefs.getStringList(_getKey());

      if (jsonList != null) {
        debugPrint('HistoryService: Found ${jsonList.length} items in persistence');
        final List<Recipe> recipes = jsonList
            .map((item) {
              try {
                return Recipe.fromJson(jsonDecode(item));
              } catch (e) {
                debugPrint('HistoryService: Failed to decode item: $e');
                return null;
              }
            })
            .whereType<Recipe>()
            .toList();
        recentlyViewedNotifier.value = recipes;
      } else {
        debugPrint('HistoryService: No history found in persistence');
      }
    } catch (e) {
      debugPrint('Error loading history: $e');
    }
  }

  Future<void> addToHistory(Recipe recipe) async {
    try {
      final List<Recipe> current = List.from(recentlyViewedNotifier.value);
      
      // Remove if already exists to move it to the top
      current.removeWhere((r) => r.id == recipe.id);
      
      // Add to start
      current.insert(0, recipe);
      debugPrint('HistoryService: Added recipe ${recipe.name} to history. Total: ${current.length}');
      
      // Limit to 15 items
      if (current.length > 15) {
        current.removeLast();
      }

      recentlyViewedNotifier.value = current;

      // Persist
      final prefs = await SharedPreferences.getInstance();
      final List<String> jsonList = current
          .map((r) => jsonEncode(r.toJson()))
          .toList();
      await prefs.setStringList(_getKey(), jsonList);
    } catch (e) {
      debugPrint('Error adding to history: $e');
    }
  }

  Future<void> clearHistory() async {
    try {
      recentlyViewedNotifier.value = [];
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_getKey());
    } catch (e) {
      debugPrint('Error clearing history: $e');
    }
  }
}
